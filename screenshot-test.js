const puppeteer = require("puppeteer");
(async () => {
  const b = await puppeteer.launch({ headless: true, args: ["--no-sandbox"] });
  const p = await b.newPage();
  await p.setViewport({width:1440,height:900});
  
  // Test page
  await p.goto("http://localhost:5199", {waitUntil: "networkidle0", timeout: 10000});
  await new Promise(r => setTimeout(r, 3000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\elmokef-test.png", fullPage: true});
  console.log("✅ Test page screenshot saved!");
  
  // Flutter app
  await p.goto("http://localhost:5181", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 5000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\elmokef-flutter.png", fullPage: true});
  console.log("✅ Flutter screenshot saved!");
  
  await b.close();
  console.log("✅ Done!");
})();
