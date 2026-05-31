import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

export const runtime = "nodejs";
export const size = { width: 1200, height: 630 };

const ACCENT = "#6468F0";
const BG = "#080A12";

export default async function Image() {
  const iconBuffer = await readFile(
    join(process.cwd(), "public", "snapfound-icon-512x512.png"),
  );
  const iconSrc = `data:image/png;base64,${iconBuffer.toString("base64")}`;

  return new ImageResponse(
    <div
      style={{
        width: 1200,
        height: 630,
        display: "flex",
        background: BG,
        fontFamily: "sans-serif",
        position: "relative",
      }}
    >
      {/* Ambient glow — top-left */}
      <div
        style={{
          position: "absolute",
          top: -180,
          left: -80,
          width: 540,
          height: 540,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(100,104,240,0.22) 0%, transparent 70%)",
        }}
      />

      {/* Left content */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          padding: "60px 0 60px 72px",
          flex: 1,
        }}
      >
        {/* Wordmark */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            marginBottom: 48,
          }}
        >
          {/* biome-ignore lint: decorative image in OG */}
          <img
            alt=""
            height={32}
            src={iconSrc}
            style={{ borderRadius: 52 }}
            width={32}
          />
          <span
            style={{
              color: "rgba(255,255,255,0.9)",
              fontSize: 19,
              fontWeight: 600,
              letterSpacing: -0.3,
            }}
          >
            SnapFound
          </span>
        </div>

        {/* Headline */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            marginBottom: 22,
          }}
        >
          <span
            style={{
              color: "white",
              fontSize: 60,
              fontWeight: 700,
              lineHeight: 1.06,
              letterSpacing: -2,
            }}
          >
            Find any screenshot
          </span>
          <span
            style={{
              color: ACCENT,
              fontSize: 60,
              fontWeight: 700,
              lineHeight: 1.06,
              letterSpacing: -2,
            }}
          >
            instantly.
          </span>
        </div>

        {/* Subtitle */}
        <div
          style={{
            color: "rgba(255,255,255,0.48)",
            fontSize: 22,
            lineHeight: 1.4,
            marginBottom: 46,
            fontWeight: 400,
          }}
        >
          Private screenshot search for iPhone.
        </div>

        {/* Badges */}
        <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
          {["Local OCR", "No account", "No tracking", "No cloud upload"].map(
            (label) => (
              <div
                key={label}
                style={{
                  background: "rgba(100,104,240,0.1)",
                  border: "1px solid rgba(100,104,240,0.28)",
                  borderRadius: 100,
                  padding: "7px 16px",
                  color: "rgba(180,182,255,0.82)",
                  fontSize: 14,
                  fontWeight: 500,
                }}
              >
                {label}
              </div>
            ),
          )}
        </div>
      </div>

      {/* Right — icon with ambient glow */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          width: 360,
          paddingRight: 56,
          background:
            "radial-gradient(circle at center, rgba(100,104,240,0.28) 0%, transparent 65%)",
        }}
      >
        {/* biome-ignore lint: decorative image in OG */}
        <img
          alt=""
          height={228}
          src={iconSrc}
          style={{ borderRadius: 52 }}
          width={228}
        />
      </div>

      {/* Footer */}
      <div
        style={{
          position: "absolute",
          bottom: 28,
          left: 72,
          color: "rgba(255,255,255,0.2)",
          fontSize: 15,
          letterSpacing: 0.5,
        }}
      >
        snapfound.app
      </div>
    </div>,
    { ...size },
  );
}
