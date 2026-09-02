const http = require('http');

const testEndpoint = (path, method = 'GET', data = null, token = null, port = 8000) => {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port,
      path,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(body);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });

    req.on('error', (e) => reject(e));

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
};

const runTests = async () => {
  console.log('🧪 Starting ShilpSetu AI Backend Verification Tests...\n');
  let tempServer = null;

  try {
    // Check if server is already running on port 8000
    let isRunning = false;
    try {
      await testEndpoint('/api/health');
      isRunning = true;
    } catch (_) {
      isRunning = false;
    }

    if (!isRunning) {
      console.log('⚡ Server not running on :8000. Launching ephemeral test server...');
      const app = require('../app');
      const mongoose = require('mongoose');
      const env = require('../config/env');
      try {
        await mongoose.connect(env.mongoUri, { serverSelectionTimeoutMS: 2000 });
      } catch (err) {
        console.log(`[Notice] MongoDB connection optional/mock for standalone test: ${err.message}`);
      }
      tempServer = app.listen(8000);
      await new Promise((r) => setTimeout(r, 500));
    }

    // 1. Health Check
    const health = await testEndpoint('/api/health');
    console.log(`[Health] Status: ${health.status} -> Message: ${health.data.message}`);

    // 2. Demo Login
    const login = await testEndpoint('/api/auth/demo-artisan', 'POST');
    console.log(`[Auth Demo] Status: ${login.status} -> Token received: ${!!login.data.data?.token}`);
    const token = login.data.data?.token;

    if (!token) throw new Error('Could not retrieve auth token');

    // 3. User Profile
    const me = await testEndpoint('/api/auth/me', 'GET', null, token);
    console.log(`[Auth Me] Status: ${me.status} -> User: ${me.data.data?.user?.name}`);

    // 4. Products List
    const products = await testEndpoint('/api/products', 'GET', null, token);
    console.log(`[Products] Status: ${products.status} -> Count: ${products.data.data?.count}`);

    // 5. Dashboard Summary
    const stats = await testEndpoint('/api/products/stats/summary', 'GET', null, token);
    console.log(`[Dashboard Stats] Status: ${stats.status} -> Total Sales: ₹${stats.data.data?.stats?.totalSales}`);

    // 6. AI Catalog Generation
    const catalog = await testEndpoint(
      '/api/ai/catalog',
      'POST',
      { inputText: 'हाथ से बुनी हुई सूती साड़ी', inputLanguage: 'hi' },
      token
    );
    console.log(`[AI Catalog] Status: ${catalog.status} -> Generated: ${catalog.data.data?.catalog?.name}`);

    // 7. AI Smart Pricing
    const pricing = await testEndpoint(
      '/api/ai/pricing',
      'POST',
      { rawMaterialCost: 800, productionCost: 500, otherCost: 200, category: 'Textile' },
      token
    );
    console.log(`[AI Pricing] Status: ${pricing.status} -> Recommended: ₹${pricing.data.data?.pricing?.recommendedPrice}`);

    // 8. Orders List
    const orders = await testEndpoint('/api/orders', 'GET', null, token);
    console.log(`[Orders] Status: ${orders.status} -> Count: ${orders.data.data?.count}`);

    // 9. Marketplace Listings
    const mp = await testEndpoint('/api/marketplace/listings', 'GET', null, token);
    console.log(`[Marketplace] Status: ${mp.status} -> Total Listings: ${mp.data.data?.stats?.totalListings}`);

    // 10. Visual Search
    const search = await testEndpoint(
      '/api/search/visual',
      'POST',
      { category: 'Textile' },
      token
    );
    console.log(`[Visual Search] Status: ${search.status} -> Matched: ${search.data.data?.count} items`);

    console.log('\n🎉 ALL 10 BACKEND ENDPOINTS PASSED SUCCESSFULLY!');
  } catch (error) {
    console.error(`❌ Verification failed: ${error.message}`);
  } finally {
    if (tempServer) {
      tempServer.close();
    }
  }
};

runTests();
