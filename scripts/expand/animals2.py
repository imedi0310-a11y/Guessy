from common import q, apply
NEW = [
 ('neck', q('هل له رقبة طويلة؟', 'Does it have a long neck?', 'A-t-il un long cou ?', '¿Tiene el cuello largo?', 'Tem pescoço comprido?')),
 ('aus', q('هل يعيش في أستراليا؟', 'Does it live in Australia?', 'Vit-il en Australie ?', '¿Vive en Australia?', 'Vive na Austrália?')),
 ('hands', q('هل له يدان يمسك بهما مثل الإنسان؟', 'Does it have hands like a human?', 'A-t-il des mains comme l’humain ?', '¿Tiene manos como un humano?', 'Tem mãos como um humano?')),
 ('ride', q('هل يركبه الإنسان؟', 'Do people ride it?', 'Est-ce qu’on le monte ?', '¿La gente lo monta?', 'As pessoas o montam?')),
 ('amer', q('هل أصله من أمريكا؟', 'Is it originally from the Americas?', 'Est-il originaire des Amériques ?', '¿Es originario de América?', 'É originário das Américas?')),
 ('talk', q('هل يستطيع تقليد الكلام؟', 'Can it imitate speech?', 'Peut-il imiter la parole ?', '¿Puede imitar el habla?', 'Consegue imitar a fala?')),
 ('huge', q('هل هو أكبر من السيارة؟', 'Is it bigger than a car?', 'Est-il plus grand qu’une voiture ?', '¿Es más grande que un coche?', 'É maior que um carro?')),
 ('fast', q('هل هو من أسرع الحيوانات في العالم؟', 'Is it one of the fastest animals?', 'Est-il parmi les animaux les plus rapides ?', '¿Es de los animales más rápidos?', 'É um dos animais mais rápidos?')),
 ('fish', q('هل هو سمكة؟', 'Is it a fish?', 'Est-ce un poisson ?', '¿Es un pez?', 'É um peixe?')),
 ('shell', q('هل له صدفة أو قوقعة صلبة؟', 'Does it have a hard shell?', 'A-t-il une carapace ou coquille ?', '¿Tiene caparazón o concha?', 'Tem casco ou concha?')),
]
OLD = {
 'neck': ['giraffe', 'camel', 'ostrich', 'flamingo', 'swan', 'goose', 'llama'],
 'aus': ['kangaroo', 'koala'],
 'hands': ['monkey', 'gorilla', 'chimpanzee', 'orangutan'],
 'ride': ['horse', 'donkey', 'camel', 'elephant'],
 'amer': ['turkey', 'llama', 'raccoon', 'skunk', 'bison', 'jaguar', 'toucan', 'hummingbird', 'sloth', 'piranha', 'iguana'],
 'talk': ['parrot'],
 'huge': ['whale', 'elephant', 'orca', 'giraffe'],
 'fast': ['cheetah', 'falcon', 'ostrich'],
 'fish': ['shark', 'seahorse', 'salmon', 'clownfish', 'stingray', 'piranha', 'goldfish'],
 'shell': ['turtle', 'snail', 'crab', 'lobster'],
}
apply('animals', NEW, OLD, [])
