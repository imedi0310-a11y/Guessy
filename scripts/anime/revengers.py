from common import q
META = dict(id='revengers', icon='🏍️', label=q('طوكيو ريفنجرز', 'Tokyo Revengers', 'Tokyo Revengers', 'Tokyo Revengers', 'Tokyo Revengers'),
            sample=q('دراكن', 'Draken', 'Draken', 'Draken', 'Draken'),
            example=q('هل هو من عصابة طومان؟', 'Is he in Toman?', 'Fait-il partie du Toman ?', '¿Es de la Toman?', 'É da Toman?'))
ATTRS = ['girl', 'villain', 'hero', 'glasses', 'scar', 'blond', 'black', 'white', 'red', 'blue', {
 'toman': q('هل هو من عصابة طومان (طوكيو مانجي)؟', 'Is it in Toman (Tokyo Manji Gang)?', 'Fait-il partie du Toman ?', '¿Es de la Toman?', 'É da Toman?'),
 'founder': q('هل هو من مؤسسي طومان؟', 'Is it a founding member of Toman?', 'Est-il fondateur du Toman ?', '¿Es fundador de la Toman?', 'É fundador da Toman?'),
 'captain': q('هل هو قائد فرقة في طومان؟', 'Is it a Toman division captain?', 'Est-il capitaine de division du Toman ?', '¿Es capitán de división de la Toman?', 'É capitão de divisão da Toman?'),
 'leader': q('هل هو زعيم عصابة؟', 'Is it a gang leader?', 'Est-ce un chef de gang ?', '¿Es líder de una pandilla?', 'É líder de gangue?'),
 'police': q('هل هو شرطي؟', 'Is it a police officer?', 'Est-ce un policier ?', '¿Es policía?', 'É policial?'),
}]
CHARS = [
 ('takemichi', '⏳', 'Takemichi Hanagaki', 'تاكيميتشي هاناغاكي', 'hero toman blond', ['تاكيميتشي', 'تاكيمتشي']),
 ('mikey', '👑', 'Mikey (Manjiro Sano)', 'مايكي (مانجيرو سانو)', 'toman founder leader blond', ['مايكي', 'مانجيرو']),
 ('draken', '🐉', 'Draken (Ken Ryuguji)', 'دراكن (كين ريوغوجي)', 'toman founder blond', ['دراكن', 'دراكين']),
 ('baji', '🐆', 'Keisuke Baji', 'كيسكي باجي', 'toman founder captain black', ['باجي']),
 ('mitsuya', '🧵', 'Takashi Mitsuya', 'تاكاشي ميتسويا', 'toman founder captain white', ['ميتسويا']),
 ('chifuyu', '🐱', 'Chifuyu Matsuno', 'تشيفويو ماتسونو', 'toman blond', ['تشيفويو']),
 ('kazutora', '🐯', 'Kazutora Hanemiya', 'كازوتورا هانيميا', 'toman founder villain', ['كازوتورا']),
 ('smiley', '😀', 'Smiley (Nahoya Kawata)', 'سمايلي', 'toman captain red', ['سمايلي']),
 ('angry', '😠', 'Angry (Souya Kawata)', 'أنغري', 'toman blue', ['انغري', 'أنجري']),
 ('hinata', '🌻', 'Hinata Tachibana', 'هيناتا تاتشيبانا', 'girl', ['هيناتا']),
 ('emma', '💛', 'Emma Sano', 'إيما سانو', 'girl blond', ['ايما', 'إيما']),
 ('naoto', '👮', 'Naoto Tachibana', 'ناوتو تاتشيبانا', 'police', ['ناوتو']),
 ('kisaki', '👓', 'Tetta Kisaki', 'تيتا كيساكي', 'villain glasses black', ['كيساكي']),
 ('hanma', '😈', 'Shuji Hanma', 'شوجي هانما', 'villain', ['هانما']),
 ('izana', '🌙', 'Izana Kurokawa', 'إيزانا كوروكاوا', 'villain leader white', ['ايزانا', 'إيزانا']),
 ('kakucho', '🎯', 'Kakucho', 'كاكوتشو', 'villain scar', ['كاكوتشو']),
 ('senju', '🌸', 'Senju Kawaragi', 'سينجو كاواراغي', 'girl leader white', ['سينجو']),
 ('taiju', '🦍', 'Taiju Shiba', 'تايجو شيبا', 'villain leader', ['تايجو']),
]
