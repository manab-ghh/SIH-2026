const mongoose = require('mongoose');
const env = require('../config/env');
const User = require('../models/User');
const Product = require('../models/Product');
const AICatalog = require('../models/AICatalog');
const Pricing = require('../models/Pricing');
const Order = require('../models/Order');
const MarketplaceListing = require('../models/MarketplaceListing');

const seedProducts = [
  {
    name: 'Handwoven Chanderi Silk Cotton Saree',
    category: 'Textile',
    material: 'Pure Chanderi Silk Cotton Blend with Zari Border',
    craftType: 'Traditional Handloom Weaving',
    color: 'Royal Indigo Blue & Golden Zari',
    size: '6.3 Meters (With Blouse)',
    quantity: 8,
    rawMaterialCost: 950,
    productionCost: 650,
    otherCost: 200,
    totalCost: 1800,
    recommendedPrice: 2899,
    minimumPrice: 2400,
    competitivePrice: 2750,
    premiumPrice: 3299,
    status: 'published',
    images: [
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Exquisite handwoven Chanderi silk cotton saree crafted by master weavers in Madhya Pradesh. Features lightweight sheer texture, intricate floral zari bootis, and natural indigo dye.',
    descriptionHindi:
      'मध्य प्रदेश के बुनकरों द्वारा तैयार की गई चंदेरी सिल्क कॉटन साड़ी। इसमें सुनहरी जरी की बारीक बूटियां और पारंपरिक प्राकृतिक रंगों का अद्भुत संगम है।',
    descriptionEnglish:
      'Exquisite handwoven Chanderi silk cotton saree with intricate gold zari booti work and sheer breathable drape.',
    keywords: ['chanderi', 'silk saree', 'handloom', 'zari', 'traditional wear', 'artisan made'],
    craftStory:
      'Weaved on traditional pit looms passed down through three generations of master weavers in Chanderi.',
  },
  {
    name: 'Traditional Terracotta Hand-Painted Vase',
    category: 'Pottery',
    material: 'Natural Riverbed Clay & Organic Pigments',
    craftType: 'Wheel-Thrown & Kiln-Fired Pottery',
    color: 'Earthy Terracotta & Ochre Yellow',
    size: '12 Inches Height',
    quantity: 14,
    rawMaterialCost: 180,
    productionCost: 250,
    otherCost: 70,
    totalCost: 500,
    recommendedPrice: 999,
    minimumPrice: 750,
    competitivePrice: 899,
    premiumPrice: 1250,
    status: 'published',
    images: [
      'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Handcrafted terracotta decorative vase shaped on a manual potter’s wheel and kiln-fired using natural wood. Adorned with heritage folk geometric motifs.',
    descriptionHindi:
      'कुम्हार के चाक पर गढ़ा गया प्राकृतिक मिट्टी का सजावटी फूलदान। लोक कला और मिट्टी की सौंधी खुशबू का एक बेमिसाल उपहार।',
    descriptionEnglish:
      'Handcrafted terracotta vase with traditional geometric tribal painting and natural clay texture.',
    keywords: ['terracotta', 'pottery', 'clay vase', 'folk art', 'home decor', 'eco friendly'],
    craftStory:
      'Crafted from fertile Gangetic alluvium soil, sun-dried for 4 days before traditional wood firing.',
  },
  {
    name: 'Bastar Tribal Dokra Brass Nandi Figurine',
    category: 'Metalware',
    material: 'Recycled Bell Metal & Brass Alloy',
    craftType: 'Lost-Wax Bell Metal Casting (Cire Perdue)',
    color: 'Antique Rustic Brass Gold',
    size: '6 x 4 x 5 Inches',
    quantity: 5,
    rawMaterialCost: 600,
    productionCost: 550,
    otherCost: 150,
    totalCost: 1300,
    recommendedPrice: 2299,
    minimumPrice: 1950,
    competitivePrice: 2199,
    premiumPrice: 2799,
    status: 'published',
    images: [
      'https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Authentic Bastar Dokra metal craft figurine depicting sacred Nandi bull. Cast using 4,000-year-old lost wax method where no two pieces are identical.',
    descriptionHindi:
      'बस्तर की विश्व प्रसिद्ध डोकरा कला से निर्मित नंदी की पीतल प्रतिमा। प्राचीन मोम ढलाई विधि से बनी अनोखी कलाकृति।',
    descriptionEnglish:
      'Authentic non-ferrous Dokra metal casting handcrafted by indigenous tribal artisans of Bastar.',
    keywords: ['dokra', 'tribal metal', 'brass figurine', 'bastar art', 'lost wax', 'antique'],
    craftStory:
      'Hand-molded using beeswax threads and clay core, preserving a metallurgical craft practiced since the Indus Valley Civilization.',
  },
  {
    name: 'Hand-Carved Sheesham Wood Jewelry Box',
    category: 'Woodwork',
    material: 'Seasoned Indian Rosewood (Sheesham) & Brass Inlay',
    craftType: 'Tarkashi (Brass Wire Inlay) & Jali Carving',
    color: 'Deep Rich Walnut Brown',
    size: '8 x 5 x 3.5 Inches',
    quantity: 10,
    rawMaterialCost: 450,
    productionCost: 400,
    otherCost: 100,
    totalCost: 950,
    recommendedPrice: 1799,
    minimumPrice: 1450,
    competitivePrice: 1699,
    premiumPrice: 2199,
    status: 'published',
    images: [
      'https://images.unsplash.com/photo-1535295972055-1c762f4483e5?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Solid Sheesham wood keepsake box featuring delicate brass floral wire inlay and velvet cushioned compartments for precious jewelry.',
    descriptionHindi:
      'शीशम की ठोस लकड़ी से बना कलात्मक आभूषण बॉक्स, जिसमें पीतल के तारों की बारीक नक्काशी की गई है।',
    descriptionEnglish:
      'Solid Sheesham wood box with traditional brass wire inlay and soft interior velvet lining.',
    keywords: ['woodwork', 'jewelry box', 'sheesham', 'brass inlay', 'tarkashi', 'hand carved'],
    craftStory:
      'Hand-chiseled by Saharanpur wood artisans with meticulous brass wire hammered into carved grooves.',
  },
  {
    name: 'Kantha Embroidered Pure Cotton Cushion Cover',
    category: 'Textile',
    material: 'Handloom Cotton Fabric & Organic Thread',
    craftType: 'Bengal Kantha Running Stitch Embroidery',
    color: 'Ivory White with Multi-Color Threadwork',
    size: '16 x 16 Inches (Set of 2)',
    quantity: 12,
    rawMaterialCost: 320,
    productionCost: 280,
    otherCost: 80,
    totalCost: 680,
    recommendedPrice: 1299,
    minimumPrice: 990,
    competitivePrice: 1199,
    premiumPrice: 1599,
    status: 'ready',
    images: [
      'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Set of 2 artisanal cushion covers decorated with continuous Kantha running stitches depicting rural nature motifs by Bengal women artisans.',
    descriptionHindi:
      'बंगाल की पारंपरिक कांथा कढ़ाई से सुसज्जित 2 कुशन कवर्स का सेट। सुंदर हस्तशिल्प और सूती आराम।',
    descriptionEnglish:
      'Set of 2 handloom cotton cushion covers with intricate hand-embroidered Kantha patterns.',
    keywords: ['kantha', 'cushion cover', 'embroidery', 'bengal craft', 'cotton', 'home textiles'],
    craftStory:
      'Stitched by rural women self-help collectives in Shantiniketan, empowering village artisans.',
  },
  {
    name: 'Handcrafted Bamboo Lattice Pendant Lamp',
    category: 'BambooCane',
    material: 'Treated Natural Assam Bamboo & Cane',
    craftType: 'Lattice Weaving & Heat Bending',
    color: 'Natural Golden Bamboo Finish',
    size: '14 x 10 Inches',
    quantity: 7,
    rawMaterialCost: 240,
    productionCost: 300,
    otherCost: 110,
    totalCost: 650,
    recommendedPrice: 1449,
    minimumPrice: 1150,
    competitivePrice: 1350,
    premiumPrice: 1799,
    status: 'draft',
    images: [
      'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Sustainable eco-friendly bamboo hanging ceiling lamp shade. Diffuses warm ambient patterns across walls, crafted from renewable Assam bamboo.',
    descriptionHindi:
      'असम के बांस से हाथ से बुना हुआ आकर्षक पेंडेंट लैंप। यह आपके लिविंग रूम को शांत और प्राकृतिक रोशनी देता है।',
    descriptionEnglish:
      'Handcrafted bamboo lattice lamp shade creating intricate shadows and sustainable ambient lighting.',
    keywords: ['bamboo lamp', 'cane craft', 'eco friendly', 'sustainable decor', 'assam craft'],
    craftStory:
      'Made from mature Golden Bamboo harvested sustainably and smoke-treated for termite protection.',
  },
  {
    name: 'Traditional Madhubani Peacock Wall Painting',
    category: 'Painting',
    material: 'Handmade Recycled Cotton Paper & Natural Dyes',
    craftType: 'Mithila / Madhubani Line Painting (Kachni & Bharni)',
    color: 'Vibrant Ochre, Indigo & Crimson',
    size: '18 x 24 Inches (Framed)',
    quantity: 4,
    rawMaterialCost: 400,
    productionCost: 700,
    otherCost: 200,
    totalCost: 1300,
    recommendedPrice: 2499,
    minimumPrice: 2000,
    competitivePrice: 2350,
    premiumPrice: 3100,
    status: 'published',
    images: [
      'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Original Mithila art painting portraying the sacred dancing peacock symbol of prosperity, hand-painted using bamboo twigs and mineral vegetable colors.',
    descriptionHindi:
      'मिथिला की विश्वप्रसिद्ध मधुबनी पेंटिंग में मोर का सुंदर चित्रण। प्राकृतिक रंगों और बांस की कलम से निर्मित।',
    descriptionEnglish:
      'Authentic Madhubani peacock folk painting created with natural vegetable colors on handmade rag paper.',
    keywords: ['madhubani', 'mithila painting', 'folk art', 'peacock art', 'wall decor', 'bihar craft'],
    craftStory:
      'Painted by heritage folk artists of Jitwarpur village following centuries-old auspicious motifs.',
  },
  {
    name: 'Handcrafted Kolhapuri Genuine Leather Jootis',
    category: 'Leatherwork',
    material: 'Vegetable-Tanned Bagda Buffalo Leather & Braided Cords',
    craftType: 'Kolhapuri Leather Craft & Hand Stitching',
    color: 'Rich Tan & Mustard Finish',
    size: 'Standard Indian Size 8',
    quantity: 0,
    rawMaterialCost: 550,
    productionCost: 450,
    otherCost: 120,
    totalCost: 1120,
    recommendedPrice: 1999,
    minimumPrice: 1650,
    competitivePrice: 1899,
    premiumPrice: 2399,
    status: 'out_of_stock',
    images: [
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&q=80&w=800',
    ],
    description:
      'Authentic handcrafted Kolhapuri slippers constructed with vegetable-tanned natural leather and traditional cord knotting. Softens naturally with wear.',
    descriptionHindi:
      'प्रामाणिक हस्तनिर्मित कोल्हापुरी चप्पल, जो शुद्ध प्राकृतिक चमड़े और हाथ की सिलाई से बनाई गई है।',
    descriptionEnglish:
      'Authentic vegetable-tanned leather Kolhapuri jootis hand-stitched by traditional cobbler clans.',
    keywords: ['kolhapuri', 'leather jooti', 'handmade footwear', 'traditional shoes', 'artisan leather'],
    craftStory:
      'Tanned using vegetable oils, myrobalan nuts, and acacia bark without toxic chromium chemicals.',
  },
];

const seedDatabase = async () => {
  try {
    await mongoose.connect(env.mongoUri);
    console.log('[Seed] Connected to MongoDB');

    // Clean existing seed collections
    await User.deleteMany({ phone: '9876543210' });
    console.log('[Seed] Cleaned old demo user');

    // 1. Create Demo Artisan
    const demoArtisan = await User.create({
      name: 'Ramu Weaver',
      phone: '9876543210',
      email: 'ramu.artisan@shilpsetu.in',
      password: 'demoPassword123',
      preferredLanguage: 'hi',
      location: 'Varanasi Handloom Cluster, Uttar Pradesh',
      craftSpecialty: 'Chanderi & Banarasi Silk Weaving',
      profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=300',
      role: 'artisan',
    });
    console.log(`[Seed] Demo Artisan created: ${demoArtisan.name} (Phone: ${demoArtisan.phone})`);

    // Clean previous demo products
    await Product.deleteMany({ artisanId: demoArtisan._id });
    await Order.deleteMany({ artisanId: demoArtisan._id });
    await MarketplaceListing.deleteMany({});

    // 2. Insert Products
    const createdProducts = [];
    for (const prodData of seedProducts) {
      const prod = await Product.create({
        ...prodData,
        artisanId: demoArtisan._id,
        marketplaceStatus: {
          ondc: prodData.status === 'published' ? 'published' : 'not_published',
          gem: prodData.status === 'published' ? 'published' : 'not_published',
        },
      });
      createdProducts.push(prod);

      // Create pricing record for each
      await Pricing.create({
        productId: prod._id,
        rawMaterialCost: prod.rawMaterialCost,
        productionCost: prod.productionCost,
        otherCost: prod.otherCost,
        totalCost: prod.totalCost,
        minimumPrice: prod.minimumPrice,
        competitivePrice: prod.competitivePrice,
        recommendedPrice: prod.recommendedPrice,
        premiumPrice: prod.premiumPrice,
        profitMargin: Math.round(((prod.recommendedPrice - prod.totalCost) / prod.recommendedPrice) * 1000) / 10,
        estimatedProfit: prod.recommendedPrice - prod.totalCost,
        marketTrend: `Strong buyer demand across Tier 1 & 2 cities for handcrafted ${prod.category}`,
        explanation: `Based on ₹${prod.totalCost} total costs, artisan labor factor, and simulated handicraft market trends.`,
      });

      // Create Marketplace Listings for published items
      if (prod.status === 'published') {
        const randOndc = Math.floor(100000 + Math.random() * 900000);
        const randGem = Math.floor(100000 + Math.random() * 900000);

        await MarketplaceListing.create({
          productId: prod._id,
          marketplace: 'ONDC',
          listingId: `ONDC-DEMO-${randOndc}`,
          status: 'Published',
          marketplaceCategory: `${prod.category} & Handlooms`,
          isSimulation: true,
        });

        await MarketplaceListing.create({
          productId: prod._id,
          marketplace: 'GeM',
          listingId: `GEM-DEMO-${randGem}`,
          status: 'Published',
          marketplaceCategory: `${prod.category} & Handicrafts`,
          isSimulation: true,
        });
      }
    }
    console.log(`[Seed] Created ${createdProducts.length} rich handicraft products & marketplace listings`);

    // 3. Create Demo Orders
    const sampleBuyers = [
      { name: 'Ananya Deshmukh', phone: '+91 98201 45892', city: 'Mumbai', state: 'Maharashtra' },
      { name: 'Rajesh Iyer', phone: '+91 97412 88391', city: 'Bengaluru', state: 'Karnataka' },
      { name: 'Sunita Mehra', phone: '+91 98110 52319', city: 'New Delhi', state: 'Delhi' },
      { name: 'Kavita Sengupta', phone: '+91 94331 67204', city: 'Kolkata', state: 'West Bengal' },
      { name: 'Vikramaditya Chauhan', phone: '+91 99280 14930', city: 'Jaipur', state: 'Rajasthan' },
    ];

    const orderStatuses = ['processing', 'shipped', 'delivered', 'pending', 'confirmed'];

    for (let i = 0; i < 5; i++) {
      const prod = createdProducts[i % createdProducts.length];
      const buyer = sampleBuyers[i];
      const status = orderStatuses[i];
      const orderNum = `SHL-${10230 + i}`;

      await Order.create({
        orderNumber: orderNum,
        productId: prod._id,
        productSnapshot: {
          name: prod.name,
          image: prod.images[0],
          category: prod.category,
          craftType: prod.craftType,
        },
        buyerName: buyer.name,
        buyerPhone: buyer.phone,
        artisanId: demoArtisan._id,
        quantity: 1,
        price: prod.recommendedPrice,
        totalAmount: prod.recommendedPrice,
        status,
        shippingAddress: {
          street: `${12 + i * 5}, Craft Villa, Heritage Enclave`,
          city: buyer.city,
          state: buyer.state,
          postalCode: `${500001 + i * 100}`,
          country: 'India',
        },
        timeline: [
          { status: 'pending', message: 'Order placed by buyer', timestamp: new Date(Date.now() - 4 * 86400000) },
          { status: 'confirmed', message: 'Order confirmed by artisan', timestamp: new Date(Date.now() - 3 * 86400000) },
          ...(status === 'processing' || status === 'shipped' || status === 'delivered'
            ? [{ status: 'processing', message: 'Crafting & premium packaging in progress', timestamp: new Date(Date.now() - 2 * 86400000) }]
            : []),
          ...(status === 'shipped' || status === 'delivered'
            ? [{ status: 'shipped', message: 'Dispatched via Craft Logistics Courier', timestamp: new Date(Date.now() - 1 * 86400000) }]
            : []),
          ...(status === 'delivered'
            ? [{ status: 'delivered', message: 'Package safely delivered to buyer', timestamp: new Date() }]
            : []),
        ],
      });
    }
    console.log(`[Seed] Created 5 active orders with timeline progressions`);

    console.log('✅ [Seed] Database successfully seeded with ShilpSetu AI demo data!');
    process.exit(0);
  } catch (error) {
    console.error(`❌ [Seed] Error seeding database: ${error.message}`);
    process.exit(1);
  }
};

seedDatabase();
