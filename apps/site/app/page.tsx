import { FAQ } from "@/components/landing/faq";
import { FeatureShowcase } from "@/components/landing/feature-showcase";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";
import { Hero } from "@/components/landing/hero";
import { HowItWorks } from "@/components/landing/how-it-works";
import { ScreenshotGallery } from "@/components/landing/screenshot-gallery";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <FeatureShowcase />
        <ScreenshotGallery />
        <HowItWorks />
        <FAQ />
      </main>
      <Footer />
    </>
  );
}
