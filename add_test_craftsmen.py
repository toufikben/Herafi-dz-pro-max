import firebase_admin
from firebase_admin import credentials, firestore
import random

# Initialize Firebase
cred = credentials.Certificate('/home/ubuntu/herafi/herafi-algeria-app/fcm-relay/service-account.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

craftsmen = [
    {
        "fullName": "سفيان تكنو كهرباء",
        "specialties": ["electricity"],
        "wilaya": "الجزائر",
        "commune": "الجزائر الوسطى",
        "phone": "+213555111222",
        "bio": "تقني سامي في الكهرباء، صيانة الأعطال المستعجلة، الطاقة الشمسية والأنظمة الذكية.",
        "yearsOfExperience": 15,
        "rating": 4.9,
        "ratingCount": 64,
        "isCraftsman": True,
        "isVerified": True,
        "photoUrl": "https://randomuser.me/api/portraits/men/1.jpg",
        "createdAt": firestore.SERVER_TIMESTAMP
    },
    {
        "fullName": "حمزة للديكور والصباغة",
        "specialties": ["painting"],
        "wilaya": "الجزائر",
        "commune": "بوزريعة",
        "phone": "+213555333444",
        "bio": "متخصص في جميع أنواع الدهانات الحديثة: ستوكو، خيال، صقلي، دهانات زيتية ومائية، عزل الرطوبة وحماية الواجهات.",
        "yearsOfExperience": 10,
        "rating": 4.8,
        "ratingCount": 56,
        "isCraftsman": True,
        "isVerified": True,
        "photoUrl": "https://randomuser.me/api/portraits/men/2.jpg",
        "createdAt": firestore.SERVER_TIMESTAMP
    },
    {
        "fullName": "ياسين لخدمات السباكة",
        "specialties": ["plumbing"],
        "wilaya": "وهران",
        "commune": "وهران",
        "phone": "+213555555666",
        "bio": "ترصيص صحي، تركيب التدفئة المركزية، تصليح تسربات المياه، وتركيب سخانات المياه.",
        "yearsOfExperience": 8,
        "rating": 4.7,
        "ratingCount": 42,
        "isCraftsman": True,
        "isVerified": False,
        "photoUrl": "https://randomuser.me/api/portraits/men/3.jpg",
        "createdAt": firestore.SERVER_TIMESTAMP
    },
    {
        "fullName": "مراد لتصليح المكيفات",
        "specialties": ["ac"],
        "wilaya": "قسنطينة",
        "commune": "قسنطينة",
        "phone": "+213555777888",
        "bio": "شحن غاز المكيفات، تنظيف وصيانة دورية، تركيب أجهزة التبريد المركزية.",
        "yearsOfExperience": 12,
        "rating": 4.9,
        "ratingCount": 89,
        "isCraftsman": True,
        "isVerified": True,
        "photoUrl": "https://randomuser.me/api/portraits/men/4.jpg",
        "createdAt": firestore.SERVER_TIMESTAMP
    },
    {
        "fullName": "عمر لخدمات النجارة",
        "specialties": ["carpentry"],
        "wilaya": "البليدة",
        "commune": "البليدة",
        "phone": "+213555999000",
        "bio": "صناعة وتصليح الأثاث الخشبي، تركيب المطابخ العصرية، والأبواب والنوافذ.",
        "yearsOfExperience": 20,
        "rating": 4.6,
        "ratingCount": 35,
        "isCraftsman": True,
        "isVerified": False,
        "photoUrl": "https://randomuser.me/api/portraits/men/5.jpg",
        "createdAt": firestore.SERVER_TIMESTAMP
    }
]

def add_craftsmen():
    batch = db.batch()
    for craftsman in craftsmen:
        # Generate a dummy UID
        doc_ref = db.collection('users').document()
        craftsman['uid'] = doc_ref.id
        batch.set(doc_ref, craftsman)
    
    batch.commit()
    print(f"Successfully added {len(craftsmen)} test craftsmen to Firestore.")

if __name__ == "__main__":
    add_craftsmen()
