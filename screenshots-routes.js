const puppeteer = require("puppeteer");
(async () => {
  const b = await puppeteer.launch({ headless: true, args: ["--no-sandbox"] });
  const p = await b.newPage();
  await p.setViewport({width:430,height:932});

  // 1. Home page - load from start
  await p.goto("http://localhost:5181", {waitUntil: "networkidle0", timeout: 20000});
  await new Promise(r => setTimeout(r, 10000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-01-home.png", fullPage: false});
  console.log("1/6 ✅ Home");

  // 2. Login page
  await p.goto("http://localhost:5181/#/login", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 8000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-02-login.png", fullPage: false});
  console.log("2/6 ✅ Login");

  // 3. Register page
  await p.goto("http://localhost:5181/#/register", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 8000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-03-register.png", fullPage: false});
  console.log("3/6 ✅ Register");

  // 4. Services / categories
  await p.goto("http://localhost:5181/#/services", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 8000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-04-services.png", fullPage: false});
  console.log("4/6 ✅ Services");

  // 5. Artisans list
  await p.goto("http://localhost:5181/#/artisans", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 8000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-05-artisans.png", fullPage: false});
  console.log("5/6 ✅ Artisans");

  // 6. Search page
  await p.goto("http://localhost:5181/#/search", {waitUntil: "networkidle0", timeout: 15000});
  await new Promise(r => setTimeout(r, 8000));
  await p.screenshot({path: "C:\\Users\\youssri\\.openclaw\\workspace\\v3-06-search.png", fullPage: false});
  console.log("6/6 ✅ Search");

  await b.close();
  console.log("\n🎉 All screenshots captured!");
})();
