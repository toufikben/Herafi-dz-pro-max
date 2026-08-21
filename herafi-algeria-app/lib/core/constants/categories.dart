/// تصنيفات الحرف المتاحة في التطبيق - قائمة شاملة للحرف الجزائرية
class CraftCategory {
  final String id;
  final String nameAr;
  final String nameFr;
  final String nameEn;
  final String icon; // اسم الأيقونة

  const CraftCategory({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
    required this.icon,
  });
}

const List<CraftCategory> kCraftCategories = [
  // --- الأشغال الكبرى والبناء ---
  CraftCategory(id: 'builder', nameAr: 'بناء وترميم', nameFr: 'Maçonnerie', nameEn: 'Builder', icon: 'construction'),
  CraftCategory(id: 'tiler', nameAr: 'بلاط وسيراميك', nameFr: 'Carreleur', nameEn: 'Tiler', icon: 'grid_view'),
  CraftCategory(id: 'painter', nameAr: 'دهان وصباغ', nameFr: 'Peintre', nameEn: 'Painter', icon: 'format_paint'),
  CraftCategory(id: 'plasterer', nameAr: 'جبس وديكور (Placo)', nameFr: 'Plâtrier / Placo', nameEn: 'Plasterer', icon: 'layers'),
  CraftCategory(id: 'welder', nameAr: 'لحام وحداد', nameFr: 'Soudeur / Ferronnier', nameEn: 'Welder', icon: 'build'),
  CraftCategory(id: 'aluminum', nameAr: 'ألومنيوم وPVC', nameFr: 'Aluminium & PVC', nameEn: 'Aluminum Worker', icon: 'window'),
  CraftCategory(id: 'carpenter', nameAr: 'نجار خشب', nameFr: 'Menuisier Bois', nameEn: 'Carpenter', icon: 'carpenter'),
  CraftCategory(id: 'glass', nameAr: 'مركب زجاج', nameFr: 'Vitrier', nameEn: 'Glazier', icon: 'branding_watermark'),
  CraftCategory(id: 'insulation', nameAr: 'عزل مائي وحراري', nameFr: 'Étanchéité', nameEn: 'Insulation', icon: 'waves'),

  // --- الكهرباء والترصيص ---
  CraftCategory(id: 'electrician', nameAr: 'كهربائي معماري', nameFr: 'Électricien Bâtiment', nameEn: 'Electrician', icon: 'bolt'),
  CraftCategory(id: 'plumber', nameAr: 'ترصيص صحي', nameFr: 'Plombier Sanitaire', nameEn: 'Plumber', icon: 'water_drop'),
  CraftCategory(id: 'heating', nameAr: 'تدفئة مركزية وغاز', nameFr: 'Chauffage Central', nameEn: 'Heating Technician', icon: 'hot_tub'),
  CraftCategory(id: 'ac_technician', nameAr: 'تكييف وتبريد', nameFr: 'Climatisation', nameEn: 'AC Technician', icon: 'ac_unit'),
  CraftCategory(id: 'solar', nameAr: 'طاقة شمسية', nameFr: 'Énergie Solaire', nameEn: 'Solar Energy', icon: 'wb_sunny'),

  // --- الإلكترونيات والتكنولوجيا ---
  CraftCategory(id: 'phone_repair', nameAr: 'تصليح هواتف', nameFr: 'Réparation Téléphones', nameEn: 'Phone Repair', icon: 'smartphone'),
  CraftCategory(id: 'pc_repair', nameAr: 'تصليح كمبيوتر', nameFr: 'Réparation PC', nameEn: 'PC Repair', icon: 'computer'),
  CraftCategory(id: 'appliance', nameAr: 'تصليح أجهزة كهرومنزلية', nameFr: 'Réparation Électroménager', nameEn: 'Appliance Repair', icon: 'home_repair_service'),
  CraftCategory(id: 'cctv', nameAr: 'كاميرات مراقبة وإنذار', nameFr: 'Installation Caméras', nameEn: 'CCTV Installer', icon: 'videocam'),
  CraftCategory(id: 'satellite', nameAr: 'تركيب أجهزة استقبال (Parabole)', nameFr: 'Installation Parabole', nameEn: 'Satellite Tech', icon: 'settings_input_antenna'),

  // --- الميكانيك والنقل ---
  CraftCategory(id: 'mechanic', nameAr: 'ميكانيك سيارات', nameFr: 'Mécanique Auto', nameEn: 'Car Mechanic', icon: 'car_repair'),
  CraftCategory(id: 'auto_electrician', nameAr: 'كهرباء سيارات', nameFr: 'Électricité Auto', nameEn: 'Auto Electrician', icon: 'flash_on'),
  CraftCategory(id: 'vulcanizer', nameAr: 'إصلاح عجلات (Vulcanisateur)', nameFr: 'Vulcanisateur', nameEn: 'Vulcanizer', icon: 'tire_repair'),
  CraftCategory(id: 'towing', nameAr: 'قطر السيارات (Depannage)', nameFr: 'Dépannage / Remorquage', nameEn: 'Towing Service', icon: 'local_shipping'),
  CraftCategory(id: 'transport', nameAr: 'نقل بضائع وأثاث', nameFr: 'Transport de marchandises', nameEn: 'Transport', icon: 'moving'),

  // --- الخدمات المنزلية والتنظيف ---
  CraftCategory(id: 'cleaner', nameAr: 'تنظيف منازل ومكاتب', nameFr: 'Nettoyage', nameEn: 'Cleaning', icon: 'cleaning_services'),
  CraftCategory(id: 'gardener', nameAr: 'بستنة وحدائق', nameFr: 'Jardinier', nameEn: 'Gardener', icon: 'yard'),
  CraftCategory(id: 'pest_control', nameAr: 'إبادة حشرات', nameFr: 'Dératisation', nameEn: 'Pest Control', icon: 'bug_report'),

  // --- الخياطة والتجميل ---
  CraftCategory(id: 'tailor', nameAr: 'خياطة وطرز', nameFr: 'Couture', nameEn: 'Tailor', icon: 'content_cut'),
  CraftCategory(id: 'barber', nameAr: 'حلاقة رجال', nameFr: 'Coiffure Homme', nameEn: 'Barber', icon: 'content_cut'),
  CraftCategory(id: 'hairdresser', nameAr: 'حلاقة وتجميل نساء', nameFr: 'Coiffure & Esthétique Femme', nameEn: 'Hairdresser', icon: 'face'),
  CraftCategory(id: 'upholsterer', nameAr: 'تنجيد أثاث (Tapissier)', nameFr: 'Tapissier', nameEn: 'Upholsterer', icon: 'chair'),

  // --- خدمات أخرى ---
  CraftCategory(id: 'cook', nameAr: 'طباخ وحلويات', nameFr: 'Cuisinier / Pâtissier', nameEn: 'Cook', icon: 'restaurant'),
  CraftCategory(id: 'delivery', nameAr: 'توصيل سريع', nameFr: 'Coursier / Livraison', nameEn: 'Delivery', icon: 'delivery_dining'),
  CraftCategory(id: 'photographer', nameAr: 'تصوير فوتوغرافي وفيديو', nameFr: 'Photographe', nameEn: 'Photographer', icon: 'camera_alt'),
  CraftCategory(id: 'other', nameAr: 'حرف أخرى', nameFr: 'Autre', nameEn: 'Other', icon: 'more_horiz'),
];
