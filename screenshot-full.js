const puppeteer = require("puppeteer");
(async () => {
  const b = await puppeteer.launch({ headless: true, args: ["--no-sandbox"] });
  const p = await b.newPage();
  await p.setViewport({width:430,height:932});
  
  // Load the app and wait for full render
  await p.goto("http://localhost:5181", {waitUntil: "networkidle0", timeout: 20000});
  console.log("Page loaded, waiting for Flutter render...");
  await new Promise(r => setTimeout(r, 10000));
  
  // Take a full-page screenshot
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-home-full.png", fullPage: true});
  console.log("✅ Home page (full)");
  
  // Get page info
  const title = await p.title();
  const text = await p.evaluate(() => document.body?.innerText?.substring(0, 200) || "empty");
  console.log("Title:", title);
  console.log("Content:", text);
  
  await b.close();
  console.log("🎉 Done!");
})();
