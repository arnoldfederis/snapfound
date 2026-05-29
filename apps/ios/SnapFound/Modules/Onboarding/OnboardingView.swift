import SwiftUI

struct OnboardingView: View {
  let onComplete: () -> Void

  @State private var currentPage = 0

  private struct Page {
    let icon: String
    let iconColor: Color
    let title: String
    let body: String
  }

  private let pages: [Page] = [
    Page(
      icon: "sparkle.magnifyingglass",
      iconColor: .accent,
      title: "Search your screenshots\nlike magic.",
      body: "SnapFound indexes screenshots only - not your full photo library."
    ),
    Page(
      icon: "lock.shield.fill",
      iconColor: .green,
      title: "Private by design",
      body:
        "Your screenshots never leave your iPhone.\nOCR and search happen locally.\nNo account. No tracking. No cloud processing."
    ),
    Page(
      icon: "iphone",
      iconColor: .indigo,
      title: "Works locally on\nyour iPhone",
      body:
        "Free indexing includes 50 screenshots.\nUnlock unlimited indexing with a one-time purchase."
    ),
  ]

  var body: some View {
    VStack(spacing: 0) {
      TabView(selection: $currentPage) {
        ForEach(pages.indices, id: \.self) { index in
          pageView(pages[index])
            .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .onChange(of: currentPage) { Haptics.selection() }

      VStack(spacing: 20) {
        pageIndicator

        Button {
          if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
          } else {
            Haptics.notification(.success)
            onComplete()
          }
        } label: {
          Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.tint, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
        }
        .animation(.easeInOut, value: currentPage)
      }
      .padding(.horizontal, 32)
      .padding(.top, 16)
      .padding(.bottom, 48)
    }
    .background(Color(.systemBackground))
  }

  private var pageIndicator: some View {
    HStack(spacing: 6) {
      ForEach(pages.indices, id: \.self) { index in
        Capsule()
          .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
          .frame(width: index == currentPage ? 24 : 8, height: 8)
          .animation(.spring(response: 0.3), value: currentPage)
      }
    }
  }

  private func pageView(_ page: Page) -> some View {
    VStack(spacing: 28) {
      Spacer()

      Image(systemName: page.icon)
        .font(.system(size: 80))
        .foregroundStyle(page.iconColor)
        .symbolRenderingMode(.hierarchical)

      VStack(spacing: 14) {
        Text(page.title)
          .font(.largeTitle.bold())
          .multilineTextAlignment(.center)

        Text(page.body)
          .font(.body)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.horizontal, 24)

      Spacer()
      Spacer()
    }
  }
}

#Preview {
  OnboardingView(onComplete: {})
}
