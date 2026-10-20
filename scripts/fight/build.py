"""Fight sports (group 'fight'): UFC, other MMA, WWE. Hand-written facts; fails on identical answer sets."""
import json, os, sys
P = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'data', 'cards.json')
def q(ar, en, fr, es, pt): return {'ar': ar, 'en': en, 'fr': fr, 'es': es, 'pt': pt}
def div(ar, en, fr, es, pt): return q(f'هل اشتهر في وزن {ar}؟', f'Is he best known as a {en}?', f'Est-il surtout connu en {fr} ?', f'¿Es conocido sobre todo en {es}?', f'É conhecido principalmente nos {pt}?')
W = {
 'woman': q('هل هي امرأة؟', 'Is it a woman?', 'Est-ce une femme ?', '¿Es una mujer?', 'É uma mulher?'),
 'hw': div('الثقيل', 'heavyweight', 'poids lourds', 'peso pesado', 'pesos-pesados'),
 'lhw': div('خفيف الثقيل', 'light heavyweight', 'mi-lourds', 'peso semipesado', 'meio-pesados'),
 'mw': div('المتوسط', 'middleweight', 'poids moyens', 'peso medio', 'pesos-médios'),
 'ww': div('الويلتر', 'welterweight', 'mi-moyens', 'peso wélter', 'meio-médios'),
 'lw': div('الخفيف', 'lightweight', 'poids légers', 'peso ligero', 'pesos-leves'),
 'fw': div('الريشة', 'featherweight', 'poids plumes', 'peso pluma', 'pesos-penas'),
 'bw': div('الديك', 'bantamweight', 'poids coqs', 'peso gallo', 'pesos-galos'),
 'flyw': div('الذبابة', 'flyweight', 'poids mouches', 'peso mosca', 'pesos-moscas'),
 'usa': q('هل هو أمريكي؟', 'Is he American?', 'Est-il américain ?', '¿Es estadounidense?', 'É americano?'),
 'bra': q('هل هو برازيلي؟', 'Is he Brazilian?', 'Est-il brésilien ?', '¿Es brasileño?', 'É brasileiro?'),
 'rus': q('هل هو من روسيا (داغستان أو الشيشان…)؟', 'Is he from Russia (Dagestan, Chechnya…)?', 'Vient-il de Russie ?', '¿Es de Rusia?', 'É da Rússia?'),
 'eur': q('هل هو أوروبي؟', 'Is he European?', 'Est-il européen ?', '¿Es europeo?', 'É europeu?'),
 'afr': q('هل أصله من أفريقيا؟', 'Is he from Africa (by birth)?', 'Est-il né en Afrique ?', '¿Nació en África?', 'Nasceu na África?'),
 'oce': q('هل هو من أستراليا أو نيوزيلندا؟', 'Is he from Australia or New Zealand?', 'Vient-il d’Australie ou de Nouvelle-Zélande ?', '¿Es de Australia o Nueva Zelanda?', 'É da Austrália ou Nova Zelândia?'),
 'asia': q('هل هو من آسيا؟', 'Is he from Asia?', 'Vient-il d’Asie ?', '¿Es de Asia?', 'É da Ásia?'),
 'arab': q('هل هو عربي؟', 'Is he Arab?', 'Est-il arabe ?', '¿Es árabe?', 'É árabe?'),
 'wrestle': q('هل خلفيته الأساسية المصارعة؟', 'Is wrestling his main background?', 'La lutte est-elle sa base ?', '¿Su base es la lucha?', 'A base é wrestling?'),
 'striker': q('هل هو مقاتل ضربات (ملاكمة، كيك بوكسينغ…)؟', 'Is he mainly a striker (boxing, kickboxing…)?', 'Est-il surtout un pieds-poings ?', '¿Es sobre todo un golpeador?', 'É principalmente um trocador?'),
 'bjj': q('هل هو خبير جوجيتسو؟', 'Is he a jiu-jitsu specialist?', 'Est-il spécialiste du jiu-jitsu ?', '¿Es especialista en jiu-jitsu?', 'É especialista em jiu-jitsu?'),
 'beard': q('هل له لحية؟', 'Does he have a beard?', 'A-t-il une barbe ?', '¿Tiene barba?', 'Tem barba?'),
 'bald': q('هل هو أصلع (رأس محلوق)؟', 'Is he bald (shaved head)?', 'Est-il chauve ?', '¿Es calvo?', 'É careca?'),
}
UFC_A = ['woman', 'champ', 'double', 'hw', 'lhw', 'mw', 'ww', 'lw', 'fw', 'bw', 'flyw', 'usa', 'bra', 'rus', 'eur', 'afr', 'oce', 'asia', 'arab',
         'wrestle', 'striker', 'bjj', 'undefeated', 'wwe', 'beard', 'bald', 'legend']
EXTRA = {
 'champ': q('هل كان بطلاً في الـ UFC؟', 'Has he been a UFC champion?', 'A-t-il été champion de l’UFC ?', '¿Ha sido campeón de UFC?', 'Já foi campeão do UFC?'),
 'double': q('هل كان بطلاً في وزنين مختلفين؟', 'Has he been champion in two divisions?', 'A-t-il été champion dans deux catégories ?', '¿Fue campeón en dos divisiones?', 'Foi campeão em duas categorias?'),
 'undefeated': q('هل اعتزل دون أي خسارة؟', 'Did he retire undefeated?', 'A-t-il pris sa retraite invaincu ?', '¿Se retiró invicto?', 'Aposentou invicto?'),
 'wwe': q('هل صارع في WWE؟', 'Has he wrestled in WWE?', 'A-t-il combattu à la WWE ?', '¿Luchó en la WWE?', 'Lutou na WWE?'),
 'legend': q('هل اشتهر قبل سنة 2010؟', 'Was he famous before 2010?', 'Était-il célèbre avant 2010 ?', '¿Era famoso antes de 2010?', 'Era famoso antes de 2010?'),
}
W.update(EXTRA)
UFC = [
 ('khabib', '🦅', 'Khabib Nurmagomedov', 'حبيب نورمحمدوف', 'champ lw rus wrestle undefeated beard', ['حبيب', 'خبيب']),
 ('islam', '🏔️', 'Islam Makhachev', 'إسلام مخاتشيف', 'champ lw rus wrestle beard', ['اسلام', 'مخاتشيف', 'مكاتشيف']),
 ('conor', '🍀', 'Conor McGregor', 'كونور ماكغريغور', 'champ double fw lw eur striker beard', ['كونور', 'ماكغريغور', 'ماكجريجور']),
 ('jones', '🦴', 'Jon Jones', 'جون جونز', 'champ double lhw hw usa wrestle', ['جونز', 'جون جونز']),
 ('silva', '🕷️', 'Anderson Silva', 'أندرسون سيلفا', 'champ mw bra striker legend', ['اندرسون', 'أندرسون سيلفا']),
 ('gsp', '🍁', 'Georges St-Pierre', 'جورج سانت بيير', 'champ double ww wrestle legend', ['سانت بيير', 'جي اس بي']),
 ('adesanya', '🎨', 'Israel Adesanya', 'إسرائيل أديسانيا', 'champ mw afr oce striker', ['اديسانيا', 'أديسانيا']),
 ('ngannou', '🦁', 'Francis Ngannou', 'فرانسيس نغانو', 'champ hw afr striker bald', ['نغانو', 'نجانو', 'نقانو']),
 ('usman', '🌍', 'Kamaru Usman', 'كامارو عثمان', 'champ ww afr usa wrestle', ['عثمان', 'كامارو']),
 ('pereira', '🏹', 'Alex Pereira', 'أليكس بيريرا', 'champ double mw lhw bra striker', ['بيريرا']),
 ('topuria', '🐐', 'Ilia Topuria', 'إيليا توبوريا', 'champ double fw lw eur striker', ['توبوريا']),
 ('volk', '🇦🇺', 'Alexander Volkanovski', 'ألكسندر فولكانوفسكي', 'champ fw oce striker', ['فولكانوفسكي', 'فولك']),
 ('nunes', '👊', 'Amanda Nunes', 'أماندا نونيس', 'woman champ double bw bra striker', ['نونيس', 'أماندا']),
 ('rousey', '🥋', 'Ronda Rousey', 'روندا راوزي', 'woman champ bw usa wwe legend', ['روندا', 'راوزي']),
 ('shevchenko', '🎯', 'Valentina Shevchenko', 'فالنتينا شيفتشينكو', 'woman champ flyw asia striker', ['شيفتشينكو', 'فالنتينا']),
 ('zhang', '🐉', 'Zhang Weili', 'تشانغ وي لي', 'woman champ asia striker', ['تشانغ', 'وي لي']),
 ('rose', '🌹', 'Rose Namajunas', 'روز ناماجوناس', 'woman champ usa striker', ['روز', 'ناماجوناس']),
 ('joanna', '🇵🇱', 'Joanna Jędrzejczyk', 'يوانا يندجيتشيك', 'woman champ eur striker', ['يوانا']),
 ('holm', '🦵', 'Holly Holm', 'هولي هولم', 'woman champ bw usa striker', ['هولي هولم']),
 ('pena', '🦁', 'Julianna Peña', 'جوليانا بينيا', 'woman champ bw usa bjj', ['بينيا']),
 ('ndiaz', '🌿', 'Nate Diaz', 'نيت دياز', 'lw ww usa bjj', ['نيت دياز', 'دياز']),
 ('poirier', '💎', 'Dustin Poirier', 'داستن بورييه', 'lw usa striker beard', ['بورييه', 'بوارييه']),
 ('gaethje', '🔥', 'Justin Gaethje', 'جاستن غيثجي', 'lw usa wrestle striker', ['غيثجي']),
 ('oliveira', '🇧🇷', 'Charles Oliveira', 'تشارلز أوليفيرا', 'champ lw bra bjj', ['اوليفيرا', 'أوليفيرا']),
 ('rda', '🦅', 'Rafael dos Anjos', 'رافائيل دوس أنجوس', 'champ lw bra bjj beard', ['دوس انجوس']),
 ('holloway', '🌺', 'Max Holloway', 'ماكس هولواي', 'champ fw usa striker', ['هولواي']),
 ('aldo', '👑', 'José Aldo', 'جوزيه ألدو', 'champ fw bra striker legend', ['ألدو', 'الدو']),
 ('cormier', '🍗', 'Daniel Cormier', 'دانيال كورمييه', 'champ double lhw hw usa wrestle beard', ['كورمييه', 'دي سي']),
 ('stipe', '🚒', 'Stipe Miocic', 'ستيبي ميوسيتش', 'champ hw usa striker bald', ['ستيبي', 'ميوسيتش']),
 ('aspinall', '🏴', 'Tom Aspinall', 'توم أسبينال', 'champ hw eur bjj', ['اسبينال', 'أسبينال']),
 ('gane', '🇫🇷', 'Ciryl Gane', 'سيريل غان', 'hw eur striker', ['غان', 'سيريل']),
 ('omalley', '🌈', 'Sean O’Malley', 'شون أومالي', 'champ bw usa striker', ['اومالي', 'أومالي']),
 ('merab', '🚂', 'Merab Dvalishvili', 'ميراب دفاليشفيلي', 'champ bw eur wrestle', ['ميراب']),
 ('cruz', '🕺', 'Dominick Cruz', 'دومينيك كروز', 'champ bw usa legend', ['كروز']),
 ('cejudo', '🥇', 'Henry Cejudo', 'هنري سيخودو', 'champ double flyw bw usa wrestle', ['سيخودو']),
 ('djohnson', '🐭', 'Demetrious Johnson', 'ديميتريوس جونسون', 'champ flyw usa', ['مايتي ماوس', 'ديميتريوس']),
 ('pantoja', '🐼', 'Alexandre Pantoja', 'أليكساندر بانتوجا', 'champ flyw bra bjj', ['بانتوجا']),
 ('dricus', '🇿🇦', 'Dricus du Plessis', 'دريكوس دو بليسيس', 'champ mw afr', ['دريكوس', 'دو بليسيس']),
 ('edwards', '🦊', 'Leon Edwards', 'ليون إدواردز', 'champ ww eur striker', ['ادواردز', 'إدواردز']),
 ('belal', '🤲', 'Belal Muhammad', 'بلال محمد', 'champ ww usa arab wrestle beard', ['بلال', 'بلال محمد']),
 ('chimaev', '🐺', 'Khamzat Chimaev', 'حمزات تشيماييف', 'champ mw rus wrestle beard', ['حمزات', 'تشيماييف', 'شيماييف']),
 ('ankalaev', '🏔️', 'Magomed Ankalaev', 'محمد أنكالاييف', 'champ lhw rus beard', ['انكالاييف', 'أنكالاييف']),
 ('prochazka', '🇨🇿', 'Jiří Procházka', 'ييري بروخازكا', 'champ lhw eur striker', ['بروخازكا', 'بروهازكا']),
 ('masvidal', '🎤', 'Jorge Masvidal', 'خورخي ماسفيدال', 'ww usa striker beard', ['ماسفيدال']),
 ('covington', '📢', 'Colby Covington', 'كولبي كوفينغتون', 'ww usa wrestle', ['كوفينغتون']),
 ('lesnar', '💪', 'Brock Lesnar', 'بروك ليسنر', 'champ hw usa wrestle wwe legend', ['ليسنر', 'بروك']),
 ('liddell', '🪓', 'Chuck Liddell', 'تشاك ليديل', 'champ lhw usa striker legend', ['ليديل']),
 ('couture', '🧔', 'Randy Couture', 'راندي كوتور', 'champ double hw lhw usa wrestle legend', ['كوتور']),
 ('hughes', '🌽', 'Matt Hughes', 'مات هيوز', 'champ ww usa wrestle legend', ['مات هيوز']),
 ('royce', '🥋', 'Royce Gracie', 'رويس غريسي', 'champ bra bjj legend', ['غريسي', 'رويس']),
 ('whittaker', '⚔️', 'Robert Whittaker', 'روبرت ويتاكر', 'champ mw oce striker', ['ويتاكر']),
 ('velasquez', '🌮', 'Cain Velasquez', 'كين فيلاسكيز', 'champ hw usa wrestle', ['فيلاسكيز']),
 ('dlewis', '🐻', 'Derrick Lewis', 'ديريك لويس', 'hw usa striker', ['ديريك لويس']),
 ('paddy', '😄', 'Paddy Pimblett', 'بادي بيمبليت', 'lw eur bjj', ['بادي', 'بيمبليت']),
 ('chandler', '🇺🇸', 'Michael Chandler', 'مايكل تشاندلر', 'lw usa wrestle', ['تشاندلر']),
]
# ---------------- other MMA (PRIDE, Bellator, ONE, PFL…) ----------------
MMA_EXTRA = {
 'champ': q('هل كان بطلاً في منظمته؟', 'Has he been champion of his promotion?', 'A-t-il été champion de son organisation ?', '¿Fue campeón de su organización?', 'Foi campeão da sua organização?'),
 'pride': q('هل اشتهر في منظمة PRIDE اليابانية؟', 'Was he a star of Japan’s PRIDE FC?', 'Était-il une star du PRIDE ?', '¿Fue estrella de PRIDE?', 'Foi estrela do PRIDE?'),
 'bellator': q('هل قاتل في Bellator؟', 'Did he fight in Bellator?', 'A-t-il combattu au Bellator ?', '¿Peleó en Bellator?', 'Lutou no Bellator?'),
 'one': q('هل قاتل في ONE Championship؟', 'Did he fight in ONE Championship?', 'A-t-il combattu au ONE Championship ?', '¿Peleó en ONE Championship?', 'Lutou no ONE Championship?'),
 'pfl': q('هل قاتل في PFL؟', 'Did he fight in the PFL?', 'A-t-il combattu au PFL ?', '¿Peleó en la PFL?', 'Lutou na PFL?'),
 'ufc': q('هل قاتل أيضاً في الـ UFC؟', 'Did he also fight in the UFC?', 'A-t-il aussi combattu à l’UFC ?', '¿Peleó también en UFC?', 'Lutou também no UFC?'),
}
MMA_A = ['woman', 'champ', 'pride', 'bellator', 'one', 'pfl', 'ufc', 'hw', 'lhw', 'mw', 'ww', 'lw', 'fw', 'flyw', 'usa', 'bra', 'rus', 'eur', 'asia', 'oce', 'afr',
         'wrestle', 'striker', 'bjj', 'bald']
MMA = [
 ('fedor', '🐻', 'Fedor Emelianenko', 'فيدور إميليانينكو', 'champ pride bellator hw rus', ['فيدور', 'الامبراطور']),
 ('crocop', '🦵', 'Mirko Cro Cop', 'ميركو كرو كوب', 'pride ufc hw eur striker', ['كرو كوب', 'ميركو']),
 ('wanderlei', '🪓', 'Wanderlei Silva', 'فاندرلي سيلفا', 'champ pride ufc mw bra striker', ['فاندرلي', 'واندرلي']),
 ('nogueira', '🐂', 'Antônio Rodrigo Nogueira', 'أنطونيو رودريغو نوغيرا', 'champ pride ufc hw bra bjj', ['نوغيرا', 'مينوتاورو']),
 ('shogun', '🌀', 'Maurício “Shogun” Rua', 'موريسيو شوغن روا', 'champ pride ufc lhw bra striker', ['شوغن']),
 ('rampage', '📿', 'Quinton “Rampage” Jackson', 'كوينتون رامبيج جاكسون', 'champ pride ufc bellator lhw usa striker', ['رامبيج']),
 ('henderson', '🥈', 'Dan Henderson', 'دان هندرسون', 'champ pride ufc mw usa wrestle', ['هندرسون']),
 ('sakuraba', '🍊', 'Kazushi Sakuraba', 'كازوشي ساكورابا', 'pride asia wrestle', ['ساكورابا']),
 ('hunt', '🗿', 'Mark Hunt', 'مارك هانت', 'pride ufc hw oce striker', ['مارك هانت']),
 ('pitbull', '🐕', 'Patrício Pitbull', 'باتريسيو بيتبول', 'champ bellator ufc fw bra', ['بيتبول']),
 ('mvp', '🥷', 'Michael “Venom” Page', 'مايكل فينوم بيج', 'bellator ufc ww eur striker', ['فينوم', 'مايكل بيج']),
 ('bader', '🧔', 'Ryan Bader', 'رايان بادر', 'champ bellator ufc hw usa wrestle', ['بادر']),
 ('nemkov', '🐺', 'Vadim Nemkov', 'فاديم نيمكوف', 'champ bellator pfl lhw rus', ['نيمكوف']),
 ('usmannurm', '🦅', 'Usman Nurmagomedov', 'عثمان نورمحمدوف', 'champ bellator pfl lw rus', ['عثمان نورمحمدوف']),
 ('djone', '🐭', 'Demetrious Johnson (ONE)', 'ديميتريوس جونسون (ONE)', 'champ one ufc flyw usa', ['مايتي ماوس']),
 ('angela', '🌸', 'Angela Lee', 'أنجيلا لي', 'woman champ one asia', ['انجيلا لي']),
 ('cyborg', '🤖', 'Cris Cyborg', 'كريس سايبورغ', 'woman champ bellator ufc pfl fw bra striker', ['سايبورغ']),
 ('kayla', '🥋', 'Kayla Harrison', 'كايلا هاريسون', 'woman champ pfl ufc usa', ['كايلا']),
 ('ngannou_pfl', '🦁', 'Francis Ngannou (PFL)', 'فرانسيس نغانو (PFL)', 'champ pfl ufc hw afr striker bald', ['نغانو']),
 ('rutten', '🇳🇱', 'Bas Rutten', 'باس روتن', 'champ ufc hw eur striker bald', ['روتن']),
]
# ---------------- WWE ----------------
WWE_A = ['woman', 'worldchamp', 'hof', 'old', 'modern', 'dead', 'actor', 'giant', 'mask', 'bald', 'beard', 'blond', 'red',
         'samoan', 'family', 'shield', 'evolution', 'heyman', 'olympic', 'ufcmma', 'usa', 'canada', 'latino', 'eur', 'afr', 'asia', 'oce', 'arab']
WWE_EXTRA = {
 'worldchamp': q('هل فاز ببطولة العالم الكبرى في WWE؟', 'Has he won a WWE world title?', 'A-t-il gagné un titre mondial WWE ?', '¿Ganó un título mundial de la WWE?', 'Ganhou um título mundial da WWE?'),
 'hof': q('هل دخل قاعة مشاهير WWE؟', 'Is he in the WWE Hall of Fame?', 'Est-il au Hall of Fame de la WWE ?', '¿Está en el Salón de la Fama de la WWE?', 'Está no Hall da Fama da WWE?'),
 'old': q('هل اشتهر قبل سنة 2000؟', 'Was he famous before 2000?', 'Était-il célèbre avant 2000 ?', '¿Era famoso antes del 2000?', 'Era famoso antes de 2000?'),
 'modern': q('هل اشتهر بعد سنة 2010؟', 'Did he become famous after 2010?', 'Est-il devenu célèbre après 2010 ?', '¿Se hizo famoso después de 2010?', 'Ficou famoso depois de 2010?'),
 'dead': q('هل توفي؟', 'Has he passed away?', 'Est-il décédé ?', '¿Ha fallecido?', 'Já faleceu?'),
 'actor': q('هل أصبح ممثلاً في أفلام هوليوود؟', 'Did he become a Hollywood movie actor?', 'Est-il devenu acteur à Hollywood ?', '¿Se hizo actor de Hollywood?', 'Virou ator de Hollywood?'),
 'giant': q('هل هو عملاق (أطول من مترين)؟', 'Is he a giant (taller than 2 m)?', 'Est-ce un géant (plus de 2 m) ?', '¿Es un gigante (más de 2 m)?', 'É um gigante (mais de 2 m)?'),
 'mask': q('هل يلبس قناعاً (ماسك)؟', 'Is he known for wearing a mask?', 'Est-il connu pour porter un masque ?', '¿Es conocido por usar máscara?', 'É conhecido por usar máscara?'),
 'blond': q('هل شعره أشقر؟', 'Is his hair blond?', 'A-t-il les cheveux blonds ?', '¿Tiene el pelo rubio?', 'Tem cabelo loiro?'),
 'red': q('هل شعره أحمر أو برتقالي؟', 'Is his hair red or orange?', 'A-t-il les cheveux roux ?', '¿Tiene el pelo rojo o naranja?', 'Tem cabelo ruivo?'),
 'samoan': q('هل هو من العائلة السامووية (أنوائي)؟', 'Is he from the Samoan Anoa’i family?', 'Fait-il partie de la famille samoane Anoa’i ?', '¿Es de la familia samoana Anoa’i?', 'É da família samoana Anoa’i?'),
 'family': q('هل أبوه مصارع مشهور أيضاً؟', 'Is his father also a famous wrestler?', 'Son père est-il aussi un catcheur célèbre ?', '¿Su padre también fue luchador famoso?', 'O pai também foi lutador famoso?'),
 'shield': q('هل كان عضواً في فريق The Shield؟', 'Was he in The Shield?', 'Faisait-il partie du Shield ?', '¿Formó parte de The Shield?', 'Fez parte do The Shield?'),
 'evolution': q('هل كان عضواً في فريق Evolution؟', 'Was he in Evolution?', 'Faisait-il partie d’Evolution ?', '¿Formó parte de Evolution?', 'Fez parte do Evolution?'),
 'ufcmma': q('هل قاتل أيضاً في الـ UFC أو الـ MMA؟', 'Did he also fight in UFC / MMA?', 'A-t-il aussi combattu en MMA / UFC ?', '¿Peleó también en MMA / UFC?', 'Lutou também no MMA / UFC?'),
 'heyman': q('هل كان مديره (مدير أعماله) بول هايمن؟', 'Was Paul Heyman his manager?', 'Paul Heyman a-t-il été son manager ?', '¿Paul Heyman fue su mánager?', 'Paul Heyman foi seu empresário?'),
 'olympic': q('هل شارك في الألعاب الأولمبية؟', 'Did he compete at the Olympics?', 'A-t-il participé aux Jeux olympiques ?', '¿Compitió en los Juegos Olímpicos?', 'Competiu nas Olimpíadas?'),
 'canada': q('هل هو كندي؟', 'Is he Canadian?', 'Est-il canadien ?', '¿Es canadiense?', 'É canadense?'),
 'latino': q('هل أصله من المكسيك أو أمريكا اللاتينية؟', 'Is he of Mexican / Latin American origin?', 'Est-il d’origine mexicaine ou latino-américaine ?', '¿Es de origen mexicano o latinoamericano?', 'Tem origem mexicana ou latino-americana?'),
}
W.update(MMA_EXTRA | WWE_EXTRA)
W['champ_ufc'] = EXTRA['champ']
WWE = [
 ('cena', '🫡', 'John Cena', 'جون سينا', 'worldchamp actor usa', ['سينا', 'جون سينا']),
 ('rock', '🪨', 'The Rock (Dwayne Johnson)', 'ذا روك (دواين جونسون)', 'worldchamp actor samoan family old bald usa', ['ذا روك', 'الصخرة', 'دواين جونسون', 'روك']),
 ('undertaker', '⚰️', 'The Undertaker', 'أندرتيكر', 'worldchamp hof old giant usa', ['اندرتيكر', 'الحانوتي', 'اندرتكر']),
 ('stonecold', '🍺', 'Stone Cold Steve Austin', 'ستون كولد ستيف أوستن', 'worldchamp hof old bald beard usa', ['ستون كولد', 'ستيف اوستن']),
 ('hogan', '💪', 'Hulk Hogan', 'هالك هوغان', 'worldchamp hof old dead actor blond usa', ['هالك هوجان', 'هوغان']),
 ('hbk', '💔', 'Shawn Michaels', 'شون مايكلز', 'worldchamp hof old blond usa', ['شون مايكلز', 'اتش بي كي']),
 ('hhh', '👑', 'Triple H', 'تريبل إتش', 'worldchamp hof old evolution usa', ['تريبل اتش', 'تربل اتش']),
 ('kane', '🔥', 'Kane', 'كين', 'worldchamp hof old giant mask bald beard usa', ['كين']),
 ('bigshow', '🦍', 'Big Show', 'بيغ شو', 'worldchamp old giant bald usa', ['بيغ شو', 'بيج شو']),
 ('andre', '🗼', 'André the Giant', 'أندريه العملاق', 'hof old dead giant actor eur', ['اندريه', 'أندريه العملاق']),
 ('rey', '🎭', 'Rey Mysterio', 'راي ميستيريو', 'worldchamp hof mask latino usa', ['راي ميستريو', 'ري مستريو', 'ميستيريو']),
 ('eddie', '🚗', 'Eddie Guerrero', 'إيدي غيريرو', 'worldchamp hof dead latino family usa', ['ايدي غيريرو', 'ادي جريرو']),
 ('batista', '🦖', 'Batista', 'باتيستا', 'worldchamp actor evolution usa', ['باتيستا', 'ديف باتيستا']),
 ('orton', '🐍', 'Randy Orton', 'راندي أورتون', 'worldchamp evolution family usa', ['اورتون', 'راندي']),
 ('flair', '🕺', 'Ric Flair', 'ريك فلير', 'worldchamp hof old evolution blond usa', ['ريك فلير']),
 ('edge', '🌟', 'Edge', 'إيدج', 'worldchamp hof blond canada', ['ايدج', 'إيدج']),
 ('brock', '🐂', 'Brock Lesnar', 'بروك ليسنر', 'worldchamp ufcmma heyman bald usa', ['ليسنر', 'بروك']),
 ('goldberg', '🛡️', 'Goldberg', 'غولدبرغ', 'worldchamp hof bald beard usa', ['غولدبرغ', 'جولدبرج']),
 ('roman', '☝️', 'Roman Reigns', 'رومان رينز', 'worldchamp samoan family shield heyman modern beard usa', ['رومان', 'رينز']),
 ('rollins', '🏗️', 'Seth Rollins', 'سيث رولينز', 'worldchamp shield modern beard usa', ['رولينز', 'سيث']),
 ('ambrose', '🐺', 'Dean Ambrose (Jon Moxley)', 'دين أمبروز', 'worldchamp shield modern usa', ['امبروز', 'موكسلي']),
 ('bryan', '🐐', 'Daniel Bryan', 'دانيال براين', 'worldchamp modern beard usa', ['دانيال براين', 'براين']),
 ('punk', '🥤', 'CM Punk', 'سي إم بانك', 'worldchamp ufcmma heyman modern usa', ['سي ام بانك', 'بانك']),
 ('styles', '🌀', 'AJ Styles', 'إيه جي ستايلز', 'worldchamp modern beard', ['ستايلز', 'اي جي ستايلز']),
 ('owens', '🥊', 'Kevin Owens', 'كيفن أوينز', 'worldchamp modern beard canada', ['اوينز', 'كيفن اوينز']),
 ('sami', '🇸🇾', 'Sami Zayn', 'سامي زين', 'modern beard canada arab', ['سامي زين']),
 ('drew', '🗡️', 'Drew McIntyre', 'درو ماكنتاير', 'worldchamp modern beard eur', ['درو', 'ماكنتاير']),
 ('sheamus', '☘️', 'Sheamus', 'شيمس', 'worldchamp beard red eur', ['شيمس', 'شيموس']),
 ('bray', '🐑', 'Bray Wyatt', 'براي وايت', 'worldchamp modern dead beard usa', ['براي وايت']),
 ('savage', '🕶️', '“Macho Man” Randy Savage', 'ماتشو مان راندي سافاج', 'worldchamp hof old dead usa', ['ماتشو مان', 'سافاج']),
 ('warrior', '🎨', 'The Ultimate Warrior', 'المحارب', 'worldchamp hof old dead', ['ألتميت ووريور', 'المحارب']),
 ('bret', '🕶️', 'Bret Hart', 'بريت هارت', 'worldchamp hof old family canada', ['بريت هارت']),
 ('angle', '🥇', 'Kurt Angle', 'كيرت أنغل', 'worldchamp hof olympic bald usa', ['كيرت انجل', 'انغل']),
 ('henry', '🏋️', 'Mark Henry', 'مارك هنري', 'worldchamp hof olympic bald beard usa', ['مارك هنري']),
 ('khali', '🇮🇳', 'The Great Khali', 'العظيم خالي', 'worldchamp giant asia', ['خالي', 'ذا جريت خالي']),
 ('yokozuna', '🍙', 'Yokozuna', 'يوكوزونا', 'worldchamp hof old dead samoan', ['يوكوزونا']),
 ('cody', '🇺🇸', 'Cody Rhodes', 'كودي رودز', 'worldchamp family modern blond usa', ['كودي رودز', 'كودي']),
 ('jey', '🎉', 'Jey Uso', 'جاي أوسو', 'worldchamp samoan family modern', ['جاي اوسو', 'الأوسوز']),
 ('gunther', '🇦🇹', 'Gunther', 'غونثر', 'worldchamp modern bald eur', ['غونثر', 'جونثر']),
 ('braun', '🧔', 'Braun Strowman', 'براون ستورمان', 'worldchamp giant modern beard usa', ['براون', 'ستورمان']),
 ('omos', '🗿', 'Omos', 'أوموس', 'giant modern bald afr', ['اوموس']),
 ('kofi', '🥞', 'Kofi Kingston', 'كوفي كينغستون', 'worldchamp afr', ['كوفي']),
 ('lashley', '💪', 'Bobby Lashley', 'بوبي لاشلي', 'worldchamp ufcmma bald usa', ['لاشلي']),
 ('bige', '🌟', 'Big E', 'بيغ إي', 'worldchamp modern bald beard usa', ['بيغ اي']),
 ('priest', '⚰️', 'Damian Priest', 'داميان بريست', 'worldchamp modern latino', ['بريست']),
 ('becky', '🍊', 'Becky Lynch', 'بيكي لينش', 'woman worldchamp modern red eur', ['بيكي', 'بيكي لينش']),
 ('charlotte', '👑', 'Charlotte Flair', 'شارلوت فلير', 'woman worldchamp family modern blond usa', ['شارلوت']),
 ('rhea', '🦇', 'Rhea Ripley', 'ريا ريبلي', 'woman worldchamp modern oce', ['ريا ريبلي']),
 ('bianca', '🏃‍♀️', 'Bianca Belair', 'بيانكا بلير', 'woman worldchamp modern usa', ['بيانكا']),
 ('alexa', '🧸', 'Alexa Bliss', 'أليكسا بليس', 'woman worldchamp modern blond usa', ['اليكسا', 'أليكسا بليس']),
 ('trish', '💖', 'Trish Stratus', 'تريش ستراتوس', 'woman worldchamp hof blond canada', ['تريش']),
 ('lita', '🔥', 'Lita', 'ليتا', 'woman worldchamp hof red usa', ['ليتا']),
 ('asuka', '🎭', 'Asuka', 'أسوكا', 'woman worldchamp modern mask asia', ['اسوكا']),
 ('rondawwe', '🥋', 'Ronda Rousey (WWE)', 'روندا راوزي (WWE)', 'woman worldchamp ufcmma modern blond actor usa', ['روندا']),
]
CATS = [
 ('ufc', '🥊', q('مقاتلو UFC', 'UFC fighters', 'Combattants UFC', 'Peleadores UFC', 'Lutadores UFC'), 'UFC fighter', UFC_A, UFC,
  q('هل كان بطلاً في الـ UFC؟', 'Has he been a UFC champion?', 'A-t-il été champion de l’UFC ?', '¿Ha sido campeón de UFC?', 'Já foi campeão do UFC?'), 'khabib'),
 ('mma', '🥋', q('أساطير MMA (PRIDE وBellator وONE)', 'MMA legends (PRIDE, Bellator, ONE)', 'Légendes du MMA', 'Leyendas del MMA', 'Lendas do MMA'), 'MMA fighter', MMA_A, MMA,
  q('هل اشتهر في منظمة PRIDE اليابانية؟', 'Was he a PRIDE FC star?', 'Était-il une star du PRIDE ?', '¿Fue estrella de PRIDE?', 'Foi estrela do PRIDE?'), 'fedor'),
 ('wwe', '🤼', q('مصارعو WWE', 'WWE wrestlers', 'Catcheurs WWE', 'Luchadores WWE', 'Lutadores WWE'), 'WWE wrestler', WWE_A, WWE,
  q('هل دخل قاعة مشاهير WWE؟', 'Is he in the WWE Hall of Fame?', 'Est-il au Hall of Fame WWE ?', '¿Está en el Salón de la Fama WWE?', 'Está no Hall da Fama WWE?'), 'undertaker'),
]
d = json.load(open(P))
ids = {c[0] for c in CATS}
pos = next((i for i, c in enumerate(d['cats']) if c['id'] in ids or c['id'] == 'coaches'), len(d['cats']))
d['cats'] = [c for c in d['cats'] if c['id'] not in ids]
pos = min(pos, len(d['cats']))
bad = False
new = []
for cid, icon, label, en, akeys, chars, example, sample in CATS:
    qs = {**W, **(MMA_EXTRA if cid == 'mma' else {})}
    if cid == 'ufc': qs['champ'] = EXTRA['champ']
    attrs = [{'key': k, 'q': qs[k]} for k in akeys]
    cards, sig = [], {}
    for i, em, nen, ar, fl, al in chars:
        f = sorted(set(fl.split()))
        for x in f: assert x in akeys, (cid, i, x)
        cards.append({'id': i, 'emoji': em, 'en': nen, 'name': {'ar': ar, 'en': nen, 'fr': nen, 'es': nen, 'pt': nen}, 'flags': f, 'aliases': al})
        sig.setdefault(tuple(f), []).append(i)
    dups = [v for v in sig.values() if len(v) > 1]
    unused = [k for k in akeys if not any(k in c['flags'] for c in cards)]
    print(cid, len(cards), 'chars', len(attrs), 'questions', 'DUPS', dups if dups else '', 'unused', unused if unused else '')
    bad |= bool(dups)
    s = next(c for c in cards if c['id'] == sample)
    new.append({'id': cid, 'icon': icon, 'en': en, 'label': label, 'example': example, 'sample': s['name'], 'people': True,
                'group': 'fight', 'attrs': attrs, 'cards': cards})
if bad: sys.exit('fix duplicates')
d['cats'][pos:pos] = new
d.setdefault('groups', {})['fight'] = {'icon': '🥊', 'label': q('فنون القتال والمصارعة', 'Fighting & wrestling', 'Combat & catch', 'Lucha y combate', 'Luta e combate')}
json.dump(d, open(P, 'w'), ensure_ascii=False, separators=(',', ':'))
