class MockSeedData {
  static final Map<String, dynamic> defaultUser = {
    'id': 'artisan_demo_001',
    '_id': 'artisan_demo_001',
    'name': 'Ramkishan Verma',
    'phone': '9876543210',
    'email': 'ramkishan.weaver@shilpsetu.in',
    'preferredLanguage': 'hi',
    'profileImage':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
    'location': 'Varanasi, Uttar Pradesh',
    'craftSpecialty': 'Banarasi Handloom & Brocade Weaving',
    'role': 'artisan',
  };

  static final List<Map<String, dynamic>> initialProducts = [
    {
      'id': 'prod_001',
      '_id': 'prod_001',
      'artisanId': 'artisan_demo_001',
      'name': 'Varanasi Pure Katan Silk Banarasi Saree',
      'description':
          'Handwoven pure Katan silk saree featuring authentic gold Zari floral jaal motifs and intricate pallu, created on traditional pit loom.',
      'descriptionHindi':
          'शुद्ध काटन सिल्क की हाथ से बुनी बनारसी साड़ी, जिसमें पारंपरिक सोने की ज़री का काम और खूबसूरत पल्लू है।',
      'descriptionEnglish':
          'Handwoven pure Katan silk saree with authentic gold Zari floral jaal and intricate kadhwa border.',
      'images': [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800',
        'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Textile',
      'material': '100% Pure Mulberry Silk & Gold Zari',
      'craftType': 'Banarasi Handloom Brocade',
      'color': 'Royal Crimson & Antique Gold',
      'size': '6.5 Meters (With Blouse Piece)',
      'quantity': 4,
      'rawMaterialCost': 3200.0,
      'productionCost': 2400.0,
      'otherCost': 600.0,
      'totalCost': 6200.0,
      'recommendedPrice': 8999.0,
      'minimumPrice': 7800.0,
      'competitivePrice': 8500.0,
      'premiumPrice': 10500.0,
      'keywords': [
        'Banarasi Saree',
        'Silk',
        'Handloom',
        'Varanasi',
        'Zari',
        'Bridal'
      ],
      'craftStory':
          'Crafted with 18 days of patient hand-weaving by master artisans in the heritage lanes of Varanasi using centuries-old pit loom techniques.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published', 'GeM': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
    },
    {
      'id': 'prod_002',
      '_id': 'prod_002',
      'artisanId': 'artisan_demo_001',
      'name': 'Jaipur Traditional Blue Pottery Decorative Vase',
      'description':
          'Authentic Jaipur blue pottery floral vase crafted from quartz powder and natural mineral oxides with Persian-inspired floral art.',
      'descriptionHindi':
          'पारंपरिक जयपुर ब्लू पॉटरी फूलदान, क्वार्ट्ज और प्राकृतिक खनिज रंगों से हाथ से चित्रित किया गया।',
      'descriptionEnglish':
          'Authentic handcrafted Jaipur blue pottery vase glazed with cobalt and turquoise floral motifs.',
      'images': [
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Pottery',
      'material': 'Quartz Stone, Fuller\'s Earth & Natural Glaze',
      'craftType': 'Jaipur Blue Pottery',
      'color': 'Turquoise Blue & White',
      'size': '10 inches (Height)',
      'quantity': 12,
      'rawMaterialCost': 450.0,
      'productionCost': 500.0,
      'otherCost': 150.0,
      'totalCost': 1100.0,
      'recommendedPrice': 1850.0,
      'minimumPrice': 1500.0,
      'competitivePrice': 1750.0,
      'premiumPrice': 2200.0,
      'keywords': [
        'Blue Pottery',
        'Jaipur',
        'Vase',
        'Handicraft',
        'Ceramic',
        'Home Decor'
      ],
      'craftStory':
          'No clay is used in this unique GI-tagged craft form. Each vessel is individually hand-turned and hand-painted by multigenerational artisans.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published', 'GeM': 'Pending'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
    },
    {
      'id': 'prod_003',
      '_id': 'prod_003',
      'artisanId': 'artisan_demo_001',
      'name': 'Bastar Tribal Dokra Bell Metal Peacock Diya',
      'description':
          'Ancient lost-wax cast bell metal peacock oil lamp crafted by tribal artisans of Chhattisgarh using 4000-year-old metallurgical traditions.',
      'descriptionHindi':
          'बस्तर की प्राचीन ढोकरा कला से बना पीतल का मयूर दीया, लुप्त मोम ढलाई तकनीक से निर्मित।',
      'descriptionEnglish':
          'Lost-wax cast bell metal peacock oil lamp created with ancient tribal metallurgy.',
      'images': [
        'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Metalware',
      'material': 'Brass & Bell Metal Alloy',
      'craftType': 'Dokra Lost-Wax Casting',
      'color': 'Rustic Antique Brass',
      'size': '8 x 5 inches',
      'quantity': 6,
      'rawMaterialCost': 700.0,
      'productionCost': 650.0,
      'otherCost': 180.0,
      'totalCost': 1530.0,
      'recommendedPrice': 2450.0,
      'minimumPrice': 2100.0,
      'competitivePrice': 2350.0,
      'premiumPrice': 2850.0,
      'keywords': [
        'Dokra',
        'Bastar',
        'Brass Diya',
        'Tribal Art',
        'Metal Craft'
      ],
      'craftStory':
          'Every piece has an individual beeswax model that is destroyed during casting, making every single diya completely one-of-a-kind.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published', 'GeM': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    },
    {
      'id': 'prod_004',
      '_id': 'prod_004',
      'artisanId': 'artisan_demo_001',
      'name': 'Kashmiri Hand-Embroidered Pashmina Shawl',
      'description':
          'Finest Changthangi Cashmere wool handwoven and needle-embroidered with intricate Kashmiri Sozni needlework floral vines.',
      'descriptionHindi':
          'कश्मीर की बारीक सोज़नी सुई की कढ़ाई वाली शुद्ध पश्मीना शॉल, अत्यंत कोमल और गर्म।',
      'descriptionEnglish':
          'Pure handwoven Cashmere Pashmina shawl with fine Kashmiri Sozni needlework.',
      'images': [
        'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Textile',
      'material': '100% Changthangi Cashmere Pashmina Wool',
      'craftType': 'Sozni Needle Embroidery',
      'color': 'Natural Ivory & Multi-color Flora',
      'size': '2 x 1 Meter',
      'quantity': 2,
      'rawMaterialCost': 5500.0,
      'productionCost': 4200.0,
      'otherCost': 800.0,
      'totalCost': 10500.0,
      'recommendedPrice': 15999.0,
      'minimumPrice': 13500.0,
      'competitivePrice': 14999.0,
      'premiumPrice': 18500.0,
      'keywords': [
        'Pashmina',
        'Kashmir',
        'Shawl',
        'Sozni',
        'Handmade Wool',
        'Luxury'
      ],
      'craftStory':
          'Spun on traditional Charkha wheels and hand-embroidered over 3 months by valley artisans keeping royal Himalayan heritage alive.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 'prod_005',
      '_id': 'prod_005',
      'artisanId': 'artisan_demo_001',
      'name': 'Channapatna Non-Toxic Wooden Stacking Toy Set',
      'description':
          'Natural Wrightia tinctoria (Ivory Wood) turned toys colored with non-toxic vegetable dyes, safe for toddlers and eco-friendly.',
      'descriptionHindi':
          'चन्नापटना के प्राकृतिक रंगों से रंगे पर्यावरण के अनुकूल बच्चों के लकड़ी के खिलौने।',
      'descriptionEnglish':
          'Eco-friendly Channapatna wooden stacking toy handcrafted with herbal vegetable lacquer dyes.',
      'images': [
        'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Woodwork',
      'material': 'Aale Mara (Ivory Wood) & Natural Vegetable Lac',
      'craftType': 'Channapatna Lacquerware',
      'color': 'Vibrant Yellow, Red & Green',
      'size': '7 Rings (6 inches tall)',
      'quantity': 18,
      'rawMaterialCost': 220.0,
      'productionCost': 280.0,
      'otherCost': 70.0,
      'totalCost': 570.0,
      'recommendedPrice': 949.0,
      'minimumPrice': 750.0,
      'competitivePrice': 899.0,
      'premiumPrice': 1150.0,
      'keywords': [
        'Channapatna',
        'Wooden Toy',
        'Non Toxic',
        'Eco Friendly',
        'GI Tag'
      ],
      'craftStory':
          'Originating during the reign of Tipu Sultan, this heritage craft uses organic turmeric, indigo and kumkum dyes polished with talc leaf.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published', 'GeM': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
    },
    {
      'id': 'prod_006',
      '_id': 'prod_006',
      'artisanId': 'artisan_demo_001',
      'name': 'Tanjore 22K Gold Foil Ganesha Sacred Painting',
      'description':
          'Traditional Thanjavur art board featuring Lord Ganesha adorned with authentic 22K gold foil leaf, Jaipur gemstones, and teak wood frame.',
      'descriptionHindi':
          '22 कैरेट सोने के वर्क और जयपुर पत्थरों से सुसज्जित पारंपरिक तंजौर भगवान गणेश चित्र।',
      'descriptionEnglish':
          'Original Tanjore devotional painting embellished with 22 Karat gold foil and semi-precious stones.',
      'images': [
        'https://images.unsplash.com/photo-1582738411706-bfc8e691d1c2?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Painting',
      'material': 'Teak Wood, Gold Leaf (22K), Natural Pigments & Glass Gems',
      'craftType': 'Tanjore Gold Leaf Painting',
      'color': 'Rich Gold & Devotional Red',
      'size': '12 x 15 inches',
      'quantity': 3,
      'rawMaterialCost': 2400.0,
      'productionCost': 1800.0,
      'otherCost': 500.0,
      'totalCost': 4700.0,
      'recommendedPrice': 6999.0,
      'minimumPrice': 5900.0,
      'competitivePrice': 6600.0,
      'premiumPrice': 7999.0,
      'keywords': [
        'Tanjore Painting',
        'Gold Foil',
        'Ganesha',
        'Traditional Art',
        'Devotional'
      ],
      'craftStory':
          'Handcrafted relief gesso work layered with genuine 22-carat gold foil that preserves its luminous sheen for generations.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published', 'GeM': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
    {
      'id': 'prod_007',
      '_id': 'prod_007',
      'artisanId': 'artisan_demo_001',
      'name': 'Moradabad Hand-Engraved Brass Urli Bowl',
      'description':
          'Traditional brass floral floating flower urli bowl with intricately chiselled peacocks and floral creepers around the rim.',
      'descriptionHindi':
          'मुरादाबाद की नक्काशीदार पीतल की पारंपरिक उरुली, फूलों और मोमबत्तियों के लिए उत्तम।',
      'descriptionEnglish':
          'Hand-engraved antique Moradabad brass floating flower and tealight urli bowl.',
      'images': [
        'https://images.unsplash.com/photo-1609137144820-7b3b3a6ef062?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Metalware',
      'material': 'Pure Heavyweight Brass',
      'craftType': 'Moradabad Brass Engraving (Kalamkari)',
      'color': 'Polished Golden Brass',
      'size': '12 inch Diameter',
      'quantity': 8,
      'rawMaterialCost': 1100.0,
      'productionCost': 750.0,
      'otherCost': 250.0,
      'totalCost': 2100.0,
      'recommendedPrice': 3299.0,
      'minimumPrice': 2700.0,
      'competitivePrice': 3100.0,
      'premiumPrice': 3800.0,
      'keywords': [
        'Brass Urli',
        'Moradabad',
        'Home Decor',
        'Diwali',
        'Floating Flowers'
      ],
      'craftStory':
          'Chiselled by hand using traditional iron burs (Kalam) by brass masters from the famous Peetal Nagri of Moradabad.',
      'status': 'draft',
      'marketplaceStatus': null,
      'createdAt':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'prod_008',
      '_id': 'prod_008',
      'artisanId': 'artisan_demo_001',
      'name': 'Assam Golden Bamboo Multi-Utility Storage Basket',
      'description':
          'Sustainable handwoven golden bamboo basket with moisture-treated smooth finish, woven by rural women collectives in Assam.',
      'descriptionHindi':
          'असम के प्राकृतिक बांस से बनी टिकाऊ और आकर्षक हस्तनिर्मित टोकरी।',
      'descriptionEnglish':
          'Handwoven Assam natural bamboo basket for fruit and artisanal storage.',
      'images': [
        'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'BambooCane',
      'material': 'Assam Jati Bamboo & Cane Fiber',
      'craftType': 'Assamese Bamboo Weaving',
      'color': 'Natural Sun-kissed Ochre',
      'size': '10 inch Diameter x 6 inch Height',
      'quantity': 15,
      'rawMaterialCost': 150.0,
      'productionCost': 280.0,
      'otherCost': 60.0,
      'totalCost': 490.0,
      'recommendedPrice': 849.0,
      'minimumPrice': 650.0,
      'competitivePrice': 799.0,
      'premiumPrice': 999.0,
      'keywords': [
        'Assam Bamboo',
        'Eco Friendly',
        'Storage Basket',
        'Handwoven',
        'Sustainable'
      ],
      'craftStory':
          'Crafted from mature 3-year bamboo harvested under full moon cycles, sliced into supple uniform strands and hand-interlocked.',
      'status': 'published',
      'marketplaceStatus': {'ONDC': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'prod_009',
      '_id': 'prod_009',
      'artisanId': 'artisan_demo_001',
      'name': 'Terracotta Natural Earthen Cooking Handi with Lid',
      'description':
          'Unglazed organic clay cooking handi that retains food nutrients, balances pH levels, and infuses authentic earthy aroma.',
      'descriptionHindi':
          'प्राकृतिक मिट्टी की शुद्ध हांडी, धीमी आंच पर पौष्टिक और स्वादिष्ट भोजन पकाने हेतु।',
      'descriptionEnglish':
          'Eco-friendly organic terracotta earthenware handi pot with steam-seal lid.',
      'images': [
        'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Pottery',
      'material': '100% Organic Riverbed Red Clay',
      'craftType': 'Earthenware Wheel Pottery',
      'color': 'Natural Terracotta Red',
      'size': '2.5 Litre Capacity',
      'quantity': 0,
      'rawMaterialCost': 120.0,
      'productionCost': 200.0,
      'otherCost': 70.0,
      'totalCost': 390.0,
      'recommendedPrice': 699.0,
      'minimumPrice': 520.0,
      'competitivePrice': 649.0,
      'premiumPrice': 849.0,
      'keywords': [
        'Terracotta',
        'Clay Pot',
        'Handi',
        'Organic Cooking',
        'Earthenware'
      ],
      'craftStory':
          'Kneaded by foot and shaped on slow-spinning wood wheels, then kiln-fired using rice husk fuel for non-toxic natural curing.',
      'status': 'out_of_stock',
      'marketplaceStatus': {'ONDC': 'Published'},
      'createdAt':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'prod_010',
      '_id': 'prod_010',
      'artisanId': 'artisan_demo_001',
      'name': 'Kutch Rogan Hand-Painted Pure Silk Stole',
      'description':
          'Rare castor oil based metallic paste art executed using a 6-inch blunt metal rod without touching the fabric directly.',
      'descriptionHindi':
          'कच्छ की दुर्लभ रोगन कला से हाथ से चित्रित शुद्ध रेशमी दुपट्टा, एरंड के तेल के रंगों से निर्मित।',
      'descriptionEnglish':
          'Authentic Kutch Rogan art hand-painted silk stole featuring traditional tree of life motif.',
      'images': [
        'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&q=80&w=800',
      ],
      'category': 'Textile',
      'material': 'Tussar Silk & Castor Oil Pigments',
      'craftType': 'Nirona Rogan Art',
      'color': 'Deep Emerald Green with Gold & White Art',
      'size': '2 Meters x 22 inches',
      'quantity': 3,
      'rawMaterialCost': 1800.0,
      'productionCost': 1600.0,
      'otherCost': 300.0,
      'totalCost': 3700.0,
      'recommendedPrice': 5499.0,
      'minimumPrice': 4800.0,
      'competitivePrice': 5200.0,
      'premiumPrice': 6500.0,
      'keywords': [
        'Rogan Art',
        'Kutch',
        'Gujarat',
        'Silk Stole',
        'Tree of Life'
      ],
      'craftStory':
          'Practiced by only one family in Nirona village of Gujarat, boiled castor seed oil paste is hand-spun into threads on palm before laying on fabric.',
      'status': 'draft',
      'marketplaceStatus': null,
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> initialOrders = [
    {
      'id': 'ord_001',
      '_id': 'ord_001',
      'orderNumber': 'SHL-20491',
      'productId': {
        '_id': 'prod_001',
        'name': 'Varanasi Pure Katan Silk Banarasi Saree',
        'images': [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800'
        ],
      },
      'productSnapshot': {
        'name': 'Varanasi Pure Katan Silk Banarasi Saree',
        'image':
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800',
      },
      'buyerName': 'Ananya Iyer',
      'buyerPhone': '+91 98450 12890',
      'quantity': 1,
      'price': 8999.0,
      'totalAmount': 8999.0,
      'status': 'pending',
      'shippingAddress': {
        'street': '402, Lotus Palms, Indiranagar 100ft Road',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'pincode': '560038',
      },
      'timeline': [
        {
          'status': 'pending',
          'message': 'Order placed via ONDC buyer app (Paytm Mall)',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 3))
              .toIso8601String(),
        }
      ],
      'createdAt':
          DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
    {
      'id': 'ord_002',
      '_id': 'ord_002',
      'orderNumber': 'SHL-20485',
      'productId': {
        '_id': 'prod_002',
        'name': 'Jaipur Traditional Blue Pottery Decorative Vase',
        'images': [
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&q=80&w=800'
        ],
      },
      'productSnapshot': {
        'name': 'Jaipur Traditional Blue Pottery Decorative Vase',
        'image':
            'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&q=80&w=800',
      },
      'buyerName': 'Rajesh Khanna',
      'buyerPhone': '+91 98201 44552',
      'quantity': 2,
      'price': 1850.0,
      'totalAmount': 3700.0,
      'status': 'confirmed',
      'shippingAddress': {
        'street': 'Flat 12B, Sea Green Towers, Worli Sea Face',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400030',
      },
      'timeline': [
        {
          'status': 'pending',
          'message': 'Order received via ONDC network (Mystore)',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 18))
              .toIso8601String(),
        },
        {
          'status': 'confirmed',
          'message':
              'Artisan confirmed order & initiated protective cushioning packaging',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 12))
              .toIso8601String(),
        }
      ],
      'createdAt':
          DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
    },
    {
      'id': 'ord_003',
      '_id': 'ord_003',
      'orderNumber': 'SHL-20478',
      'productId': {
        '_id': 'prod_003',
        'name': 'Bastar Tribal Dokra Bell Metal Peacock Diya',
        'images': [
          'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?auto=format&fit=crop&q=80&w=800'
        ],
      },
      'productSnapshot': {
        'name': 'Bastar Tribal Dokra Bell Metal Peacock Diya',
        'image':
            'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?auto=format&fit=crop&q=80&w=800',
      },
      'buyerName': 'Meera Patel',
      'buyerPhone': '+91 97129 88341',
      'quantity': 1,
      'price': 2450.0,
      'totalAmount': 2450.0,
      'status': 'shipped',
      'shippingAddress': {
        'street': '7, Shantigram Bungalows, SG Highway',
        'city': 'Ahmedabad',
        'state': 'Gujarat',
        'pincode': '380054',
      },
      'timeline': [
        {
          'status': 'pending',
          'message': 'Order placed via Government e-Marketplace (GeM)',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        },
        {
          'status': 'confirmed',
          'message': 'Order accepted by artisan',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2, hours: -4))
              .toIso8601String(),
        },
        {
          'status': 'shipped',
          'message':
              'Handed over to India Post Speed Post (AWB: IN948271038IN)',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        }
      ],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'ord_004',
      '_id': 'ord_004',
      'orderNumber': 'SHL-20462',
      'productId': {
        '_id': 'prod_005',
        'name': 'Channapatna Non-Toxic Wooden Stacking Toy Set',
        'images': [
          'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&q=80&w=800'
        ],
      },
      'productSnapshot': {
        'name': 'Channapatna Non-Toxic Wooden Stacking Toy Set',
        'image':
            'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?auto=format&fit=crop&q=80&w=800',
      },
      'buyerName': 'Vikram Sengupta',
      'buyerPhone': '+91 98310 99201',
      'quantity': 3,
      'price': 949.0,
      'totalAmount': 2847.0,
      'status': 'delivered',
      'shippingAddress': {
        'street': '14/B, Southern Avenue, Lake Area',
        'city': 'Kolkata',
        'state': 'West Bengal',
        'pincode': '700029',
      },
      'timeline': [
        {
          'status': 'pending',
          'message': 'Order placed via ONDC (Magicpin)',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 6))
              .toIso8601String(),
        },
        {
          'status': 'shipped',
          'message': 'Dispatched via Delhivery Express',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 4))
              .toIso8601String(),
        },
        {
          'status': 'delivered',
          'message':
              'Delivered safely to customer. Verified 5-star rating received!',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        }
      ],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
    },
    {
      'id': 'ord_005',
      '_id': 'ord_005',
      'orderNumber': 'SHL-20450',
      'productId': {
        '_id': 'prod_006',
        'name': 'Tanjore 22K Gold Foil Ganesha Sacred Painting',
        'images': [
          'https://images.unsplash.com/photo-1582738411706-bfc8e691d1c2?auto=format&fit=crop&q=80&w=800'
        ],
      },
      'productSnapshot': {
        'name': 'Tanjore 22K Gold Foil Ganesha Sacred Painting',
        'image':
            'https://images.unsplash.com/photo-1582738411706-bfc8e691d1c2?auto=format&fit=crop&q=80&w=800',
      },
      'buyerName': 'Dr. S. Ramaswamy',
      'buyerPhone': '+91 94440 56781',
      'quantity': 1,
      'price': 6999.0,
      'totalAmount': 6999.0,
      'status': 'delivered',
      'shippingAddress': {
        'street': '22, TTK Road, Alwarpet',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'pincode': '600018',
      },
      'timeline': [
        {
          'status': 'pending',
          'message': 'Order placed via GeM Government Portal',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 10))
              .toIso8601String(),
        },
        {
          'status': 'delivered',
          'message': 'Delivered in wooden crate packaging.',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 6))
              .toIso8601String(),
        }
      ],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> initialMarketplaceListings = [
    {
      'id': 'mkt_001',
      '_id': 'mkt_001',
      'productId': 'prod_001',
      'marketplace': 'ONDC',
      'listingId': 'ONDC-IN-984210',
      'status': 'Published',
      'marketplaceCategory': 'Handicrafts & Handlooms / Sarees',
      'publishedAt':
          DateTime.now().subtract(const Duration(days: 11)).toIso8601String(),
    },
    {
      'id': 'mkt_002',
      '_id': 'mkt_002',
      'productId': 'prod_001',
      'marketplace': 'GeM',
      'listingId': 'GEM-CRAFT-772901',
      'status': 'Published',
      'marketplaceCategory': 'Textiles & Handloom / Silk Weaves',
      'publishedAt':
          DateTime.now().subtract(const Duration(days: 11)).toIso8601String(),
    },
    {
      'id': 'mkt_003',
      '_id': 'mkt_003',
      'productId': 'prod_002',
      'marketplace': 'ONDC',
      'listingId': 'ONDC-IN-448291',
      'status': 'Published',
      'marketplaceCategory': 'Home Decor / Pottery & Ceramics',
      'publishedAt':
          DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
    },
    {
      'id': 'mkt_004',
      '_id': 'mkt_004',
      'productId': 'prod_003',
      'marketplace': 'ONDC',
      'listingId': 'ONDC-IN-619280',
      'status': 'Published',
      'marketplaceCategory': 'Spiritual & Pooja / Brass Craft',
      'publishedAt':
          DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
    },
    {
      'id': 'mkt_005',
      '_id': 'mkt_005',
      'productId': 'prod_003',
      'marketplace': 'GeM',
      'listingId': 'GEM-CRAFT-552019',
      'status': 'Published',
      'marketplaceCategory': 'Handicrafts / Metalware',
      'publishedAt':
          DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
    },
  ];
}
