import SwiftData
import SwiftUI

// MARK: - Cell

final class PhotoCarouselCell: UICollectionViewCell {
    static let reuseID = "PhotoCarouselCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 14
        iv.layer.cornerCurve = .continuous
        iv.backgroundColor = UIColor.secondarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    private var loadTask: Task<Void, Never>?
    private var currentAssetID: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    @MainActor
    func configure(with record: ScreenshotRecord) {
        loadTask?.cancel()
        currentAssetID = record.assetID

        // Show cached thumbnail immediately if available
        if let data = record.thumbnailData, let image = UIImage(data: data) {
            imageView.image = image
            activityIndicator.stopAnimating()
            return
        }

        imageView.image = nil
        activityIndicator.startAnimating()

        let assetID = record.assetID
        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let data = try await PhotoLibraryService.shared.loadThumbnailData(for: assetID)
                guard currentAssetID == assetID else { return }
                UIView.transition(
                    with: imageView,
                    duration: 0.2,
                    options: [.transitionCrossDissolve, .allowUserInteraction]
                ) {
                    self.imageView.image = UIImage(data: data)
                }
                activityIndicator.stopAnimating()
            } catch {
                activityIndicator.stopAnimating()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        currentAssetID = nil
        imageView.image = nil
        activityIndicator.startAnimating()
    }
}

// MARK: - Carousel View

struct PhotoCarouselView: UIViewRepresentable {
    let records: [ScreenshotRecord]
    var onSelect: (ScreenshotRecord) -> Void = { _ in }

    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            PhotoCarouselCell.self,
            forCellWithReuseIdentifier: PhotoCarouselCell.reuseID
        )
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        return collectionView
    }

    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        context.coordinator.records = records
        context.coordinator.onSelect = onSelect
        collectionView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(records: records, onSelect: onSelect)
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.82),
            heightDimension: .absolute(260)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 0, trailing: 16
        )

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var records: [ScreenshotRecord]
        var onSelect: (ScreenshotRecord) -> Void

        init(records: [ScreenshotRecord], onSelect: @escaping (ScreenshotRecord) -> Void) {
            self.records = records
            self.onSelect = onSelect
        }

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            records.count
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoCarouselCell.reuseID,
                for: indexPath
            ) as! PhotoCarouselCell
            cell.configure(with: records[indexPath.item])
            return cell
        }

        func collectionView(
            _ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath
        ) {
            onSelect(records[indexPath.item])
        }
    }
}
