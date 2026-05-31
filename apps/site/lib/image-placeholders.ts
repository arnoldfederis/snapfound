const svgToDataUrl = (svg: string) =>
  `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`;

export const deviceBlurDataURL = svgToDataUrl(`
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 96">
    <defs>
      <linearGradient id="g" x1="0" x2="1" y1="0" y2="1">
        <stop offset="0%" stop-color="#e7e7fb"/>
        <stop offset="50%" stop-color="#cfd2ff"/>
        <stop offset="100%" stop-color="#a6abff"/>
      </linearGradient>
    </defs>
    <rect width="48" height="96" rx="10" fill="url(#g)"/>
  </svg>
`);

export const iconBlurDataURL = svgToDataUrl(`
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
    <defs>
      <linearGradient id="g" x1="0" x2="1" y1="0" y2="1">
        <stop offset="0%" stop-color="#7a7ff5"/>
        <stop offset="100%" stop-color="#4b51d9"/>
      </linearGradient>
    </defs>
    <rect width="32" height="32" rx="8" fill="url(#g)"/>
  </svg>
`);
