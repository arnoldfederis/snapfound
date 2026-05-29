import { FAQ } from "@/components/landing/faq";
import { FeatureGrid } from "@/components/landing/feature-grid";
import { FinalCTA } from "@/components/landing/final-cta";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";
import { Hero } from "@/components/landing/hero";
import { HowItWorks } from "@/components/landing/how-it-works";
import { Pricing } from "@/components/landing/pricing";
import { PrivacySection } from "@/components/landing/privacy-section";
import { PrivacyStrip } from "@/components/landing/privacy-strip";
import { Problem } from "@/components/landing/problem";
import { UseCases } from "@/components/landing/use-cases";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <PrivacyStrip />
        <Problem />
        <FeatureGrid />
        <HowItWorks />
        <UseCases />
        <PrivacySection />
        <Pricing />
        <FAQ />
        <FinalCTA />
      </main>
      <Footer />
    </>
  );
}
