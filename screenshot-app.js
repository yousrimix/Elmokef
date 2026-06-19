const puppeteer = require("puppeteer");
(async () => {
  const b = await puppeteer.launch({ headless: true, args: ["--no-sandbox"] });
  const p = await b.newPage();
  await p.setViewport({width:430,height:932}); // Mobile view
  
  // Home page
  await p.goto("http://localhost:5181", {waitUntil: "networkidle0", timeout: 20000});
  await new Promise(r => setTimeout(r, 8000)); // Wait for Flutter to render
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3a-home.png", fullPage: false});
  console.log("1/4 ✅ Home page");
  
  await new Promise(r => setTimeout(r, 2000));
  
  // Login page
  await p.goto("http://localhost:5181/#/login", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 5000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3b-login.png", fullPage: false});
  console.log("2/4 ✅ Login page");
  
  // Services page
  await p.goto("http://localhost:5181/#/services", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 5000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3c-services.png", fullPage: false});
  console.log("3/4 ✅ Services page");
  
  // Artisans page  
  await p.goto("http://localhost:5181/#/artisans", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 5000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3d-artisans.png", fullPage: false});
  console.log("4/4 ✅ Artisans page");
  
  await b.close();
  console.log("\n🎉 All screenshots taken!");
})();
