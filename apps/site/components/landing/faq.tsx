import { FadeIn } from "@/components/common/motion";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const FAQS = [
  {
    q: "Does SnapFound upload my screenshots?",
    a: "No. OCR, tagging, indexing, and search all happen on your iPhone. Your screenshots, OCR text, and search queries are not uploaded.",
  },
  {
    q: "Does SnapFound need an account?",
    a: "No account is required. SnapFound works entirely on-device with no sign-in.",
  },
  {
    q: "Does it search all photos?",
    a: "SnapFound is designed for screenshots. It focuses on your screenshot library, not your entire photo collection.",
  },
  {
    q: "What can I search for?",
    a: "Receipts, Wi-Fi passwords, order confirmations, flights, bookings, error messages, verification codes, notes, and more. Any text that appears in an indexed screenshot.",
  },
  {
    q: "Does it work offline?",
    a: "Yes. Once screenshots are indexed, search works locally - no internet connection required.",
  },
  {
    q: "Is SnapFound a subscription?",
    a: "No. SnapFound Pro is a one-time purchase with no recurring charges.",
  },
];

export function FAQ() {
  return (
    <section className="border-t py-24" id="faq">
      <div className="mx-auto max-w-3xl">
        <FadeIn className="mb-14 px-6 text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Frequently asked questions
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Everything you need to know about SnapFound.
          </p>
        </FadeIn>

        <FadeIn delay={0.2}>
          <Accordion className="border-0 px-2 md:px-0">
            {FAQS.map(({ q, a }) => (
              <AccordionItem key={q} value={q}>
                <AccordionTrigger className="cursor-pointer">
                  {q}
                </AccordionTrigger>
                <AccordionContent>
                  <p>{a}</p>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </FadeIn>
      </div>
    </section>
  );
}
