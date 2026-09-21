import 'package:fridge/domain/entity/shelf_life.dart';

/// 가정 보관 기준의 권장 소비 기한이다.
/// 냉장은 0~4도, 냉동은 영하 18도, 실온은 서늘하고 그늘진 곳을 가정한다.
///
/// 가공식품은 식약처 소비기한 참고값(미개봉 실험치)에 가정에서 개봉 후
/// 쓰는 상황을 감안해 안전 마진을 적용했다. 신선 원물은 USDA
/// FoodKeeper/FoodSafety.gov 냉장·냉동 보관 기준을 우선 참고했다.
/// 두 출처 모두 해당 품목이 없으면 같은 카테고리의 근연 품목 값을
/// 근거로 보수적으로 추정했다 — 항목별 주석에 근거를 남긴다.
abstract final class ShelfLifeTable {
  static const entries = <ShelfLife>[
    // 육류
    // USDA FoodKeeper: raw pork chops, refrigerator 3–5 days,
    // freezer 4–6 months
    ShelfLife(
      name: '돼지고기',
      fridgeDays: 4,
      freezerDays: 150,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: raw beef steak/roast, refrigerator 3–5 days, freezer 6–12 months
    ShelfLife(
      name: '소고기',
      fridgeDays: 4,
      freezerDays: 180,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: raw poultry(whole), refrigerator 1–2 days,
    // freezer 9–12 months
    ShelfLife(
      name: '닭고기',
      fridgeDays: 2,
      freezerDays: 270,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: ground beef, refrigerator 1–2 days, freezer 3–4 months
    ShelfLife(
      name: '다짐육',
      fridgeDays: 2,
      freezerDays: 120,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(돼지고기, USDA raw pork) 기준 추정
    ShelfLife(
      name: '삼겹살',
      fridgeDays: 4,
      freezerDays: 150,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(pork shoulder, USDA raw pork 동일 카테고리) 기준 추정
    ShelfLife(
      name: '목살',
      fridgeDays: 4,
      freezerDays: 150,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: bacon opened, refrigerator 7 days, freezer 1 month
    ShelfLife(
      name: '베이컨',
      fridgeDays: 7,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음(식약처 미개봉 참고값 57일은 개봉 전) - 유사 가공육 개봉 후
    // 기준(냉장 3~5일, 냉동 1~2개월)을 근거로 가정용 보수적으로 추정
    ShelfLife(
      name: '햄',
      fridgeDays: 5,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: hot dogs opened, refrigerator 1 week, freezer 1–2 months
    // (식약처 미개봉 참고값 56일은 개봉 전 기준이라 미채택)
    ShelfLife(
      name: '소시지',
      fridgeDays: 7,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: raw chicken breast, refrigerator 1–2 days,
    // freezer 9 months
    ShelfLife(
      name: '닭가슴살',
      fridgeDays: 2,
      freezerDays: 270,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 수산물
    // USDA FoodKeeper: fatty fish(mackerel), refrigerator 1–2 days,
    // freezer 2–3 months
    ShelfLife(
      name: '고등어',
      fridgeDays: 1,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: '마리',
    ),
    // USDA FoodKeeper: fatty fish(salmon), refrigerator 1–2 days,
    // freezer 2–3 months
    ShelfLife(
      name: '연어',
      fridgeDays: 1,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(lean fish, USDA refrigerator 1–2 days,
    // freezer 4–6 months) 기준 추정
    ShelfLife(
      name: '갈치',
      fridgeDays: 1,
      freezerDays: 120,
      pantryDays: 1,
      defaultUnit: '마리',
    ),
    // USDA FoodKeeper: squid, refrigerator 1–2 days, freezer 3–12 months
    ShelfLife(
      name: '오징어',
      fridgeDays: 1,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: '마리',
    ),
    // USDA FoodKeeper: shrimp, refrigerator 1–2 days, freezer 3–6 months
    ShelfLife(
      name: '새우',
      fridgeDays: 1,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: shucked clams, refrigerator 1–2 days, freezer 3–6 months
    ShelfLife(
      name: '조개',
      fridgeDays: 1,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 건조 수산물(USDA dried jerky 계열) 기준 보수적으로 추정
    ShelfLife(
      name: '멸치',
      fridgeDays: 90,
      freezerDays: 180,
      pantryDays: 90,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 건조 생선, 멸치와 동일 로직으로 추정
    ShelfLife(
      name: '북어',
      fridgeDays: 90,
      freezerDays: 180,
      pantryDays: 90,
      defaultUnit: 'g',
    ),
    // 식약처 소비기한 참고값: 42일(미개봉, 어묵류 평균) - 개봉 후
    // 가정용 안전 마진을 적용해 단축
    ShelfLife(
      name: '어묵',
      fridgeDays: 5,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(어묵, 식약처 참고값 42일 미개봉) 기준 개봉 후 추정
    ShelfLife(
      name: '게맛살',
      fridgeDays: 5,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 유제품 · 달걀
    // USDA/FDA: opened milk, refrigerator 5–7 days - 국내 개봉 후 관행을
    // 반영해 더 보수적으로 채택
    ShelfLife(
      name: '우유',
      fridgeDays: 3,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'mL',
    ),
    // 자료 없음(식약처 발효유 미개봉 참고값 32일) - 개봉 후 유사
    // 발효유 기준(1~2주)을 근거로 추정
    ShelfLife(
      name: '요거트',
      fridgeDays: 10,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: hard cheese opened, refrigerator 3–4 weeks
    ShelfLife(
      name: '치즈',
      fridgeDays: 21,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: butter, refrigerator 1–2 months,
    // freezer 6–9 months, room temp 1–2 days
    ShelfLife(
      name: '버터',
      fridgeDays: 45,
      freezerDays: 240,
      pantryDays: 2,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 유제품(heavy cream opened, 약 1주) 기준 추정
    ShelfLife(
      name: '생크림',
      fridgeDays: 7,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: 'mL',
    ),
    // USDA FoodKeeper: eggs fresh in shell, refrigerator 3–5 weeks(하한 채택)
    ShelfLife(
      name: '계란',
      fridgeDays: 21,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(계란, quail egg refrigerator 21~35일) 기준 추정
    ShelfLife(
      name: '메추리알',
      fridgeDays: 21,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(우유, 개봉 후 유질 식품 특성) 기준 추정
    ShelfLife(
      name: '두유',
      fridgeDays: 5,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'mL',
    ),
    // 채소
    // USDA FoodKeeper: onion dry, refrigerator 2 months, pantry 1 month
    ShelfLife(
      name: '양파',
      fridgeDays: 60,
      freezerDays: 180,
      pantryDays: 30,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: green onions/scallions, refrigerator 7–14 days
    ShelfLife(
      name: '대파',
      fridgeDays: 10,
      freezerDays: 90,
      pantryDays: 3,
      defaultUnit: '단',
    ),
    // USDA FoodKeeper: garlic unbroken bulb, pantry 1 month(가정 보관
    // 관행 반영해 냉장·실온 값을 통마늘 기준으로 채택)
    ShelfLife(
      name: '마늘',
      fridgeDays: 90,
      freezerDays: 180,
      pantryDays: 30,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: ginger root, refrigerator 2–5 days
    ShelfLife(
      name: '생강',
      fridgeDays: 5,
      freezerDays: 180,
      pantryDays: 7,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: potatoes, refrigerator 1–2 weeks,
    // pantry 1–2 months(냉동 부적합)
    ShelfLife(
      name: '감자',
      fridgeDays: 21,
      freezerDays: 1,
      pantryDays: 60,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(감자류, USDA sweet potato pantry 2~3주) 기준 추정, 냉동 부적합
    ShelfLife(
      name: '고구마',
      fridgeDays: 14,
      freezerDays: 1,
      pantryDays: 21,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: carrots, refrigerator 2–3 weeks
    ShelfLife(
      name: '당근',
      fridgeDays: 21,
      freezerDays: 270,
      pantryDays: 7,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(radish, USDA refrigerator 1~2주) 기준 추정
    ShelfLife(
      name: '무',
      fridgeDays: 14,
      freezerDays: 270,
      pantryDays: 7,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(cabbage, USDA refrigerator 1~2주) 기준 추정
    ShelfLife(
      name: '배추',
      fridgeDays: 14,
      freezerDays: 90,
      pantryDays: 3,
      defaultUnit: '포기',
    ),
    // USDA FoodKeeper: cabbage, refrigerator 1–2 weeks
    ShelfLife(
      name: '양배추',
      fridgeDays: 14,
      freezerDays: 90,
      pantryDays: 5,
      defaultUnit: '포기',
    ),
    // 자료 없음 - 근연 품목(leaf lettuce, USDA refrigerator 3~7일) 하한 채택, 냉동 부적합
    ShelfLife(
      name: '상추',
      fridgeDays: 7,
      freezerDays: 1,
      pantryDays: 2,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: spinach, refrigerator 3–5 days
    ShelfLife(
      name: '시금치',
      fridgeDays: 5,
      freezerDays: 270,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음(미국 자료에 대응 품목 없음) - 근연 품목(허브류,
    // USDA fresh herbs refrigerator 7~10일) 하한 채택, 냉동 부적합
    ShelfLife(
      name: '깻잎',
      fridgeDays: 5,
      freezerDays: 1,
      pantryDays: 1,
      defaultUnit: '장',
    ),
    // 자료 없음 - 근연 품목(green onion, USDA 7~14일) 대비 얇은 잎 특성상 보수적으로 단축 추정
    ShelfLife(
      name: '부추',
      fridgeDays: 5,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: cucumber, refrigerator 4–6 days(냉동 부적합)
    ShelfLife(
      name: '오이',
      fridgeDays: 5,
      freezerDays: 1,
      pantryDays: 3,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: summer squash/zucchini, refrigerator 1–5 days
    ShelfLife(
      name: '애호박',
      fridgeDays: 5,
      freezerDays: 90,
      pantryDays: 3,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: eggplant, refrigerator 4–7 days
    ShelfLife(
      name: '가지',
      fridgeDays: 5,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: tomato, refrigerator 3–14 days(중간값), counter 3–10일
    ShelfLife(
      name: '토마토',
      fridgeDays: 7,
      freezerDays: 90,
      pantryDays: 5,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(토마토, USDA 동일 카테고리) 기준 추정
    ShelfLife(
      name: '방울토마토',
      fridgeDays: 7,
      freezerDays: 90,
      pantryDays: 5,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: bell pepper, refrigerator 4–14 days
    ShelfLife(
      name: '파프리카',
      fridgeDays: 10,
      freezerDays: 240,
      pantryDays: 3,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(파프리카, USDA bell pepper) 기준 추정
    ShelfLife(
      name: '피망',
      fridgeDays: 10,
      freezerDays: 240,
      pantryDays: 3,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: hot/chili pepper, refrigerator 2–3 weeks
    ShelfLife(
      name: '고추',
      fridgeDays: 14,
      freezerDays: 240,
      pantryDays: 3,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: broccoli raw, refrigerator 3–5 days
    ShelfLife(
      name: '브로콜리',
      fridgeDays: 5,
      freezerDays: 300,
      pantryDays: 1,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: mushroom whole, refrigerator 4–7 days
    ShelfLife(
      name: '버섯',
      fridgeDays: 5,
      freezerDays: 270,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(버섯, USDA mushroom whole 4~7일) 기준 추정
    ShelfLife(
      name: '표고버섯',
      fridgeDays: 5,
      freezerDays: 270,
      pantryDays: 3,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(버섯류) 기준 추정
    ShelfLife(
      name: '팽이버섯',
      fridgeDays: 5,
      freezerDays: 270,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(sprouts, refrigerator 3~5일) 하한 채택,
    // 부패 위험 식품이라 냉동·실온 부적합
    ShelfLife(
      name: '콩나물',
      fridgeDays: 3,
      freezerDays: 1,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(bean sprouts, 콩나물과 동일 로직) 추정
    ShelfLife(
      name: '숙주',
      fridgeDays: 3,
      freezerDays: 1,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: corn, refrigerator 1–2 days
    ShelfLife(
      name: '옥수수',
      fridgeDays: 2,
      freezerDays: 240,
      pantryDays: 1,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: peas, refrigerator 3–5 days
    ShelfLife(
      name: '완두콩',
      fridgeDays: 5,
      freezerDays: 240,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음(미국 자료 부재) - 근연 뿌리채소(parsnip류)보다 수분이
    // 많은 특성을 감안해 보수적으로 단축 추정
    ShelfLife(
      name: '연근',
      fridgeDays: 7,
      freezerDays: 180,
      pantryDays: 5,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 뿌리채소(parsnip, USDA 2~3주) 기준 추정
    ShelfLife(
      name: '우엉',
      fridgeDays: 14,
      freezerDays: 180,
      pantryDays: 7,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(대파, USDA green onion 7~14일) 기준 추정
    ShelfLife(
      name: '쪽파',
      fridgeDays: 10,
      freezerDays: 90,
      pantryDays: 3,
      defaultUnit: '단',
    ),
    // 자료 없음 - 근연 품목(허브·잎채소류, USDA fresh herbs 3~7일) 하한 채택, 냉동 부적합
    ShelfLife(
      name: '미나리',
      fridgeDays: 5,
      freezerDays: 1,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 과일
    // USDA FoodKeeper: apples, refrigerator 4–6 weeks
    ShelfLife(
      name: '사과',
      fridgeDays: 30,
      freezerDays: 240,
      pantryDays: 10,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(사과, USDA apples/pears 동일 카테고리) 기준 추정
    ShelfLife(
      name: '배',
      fridgeDays: 30,
      freezerDays: 240,
      pantryDays: 7,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: citrus, refrigerator 2–3 weeks(하한 채택)
    ShelfLife(
      name: '귤',
      fridgeDays: 21,
      freezerDays: 90,
      pantryDays: 7,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: citrus(oranges), refrigerator 3–4 weeks
    ShelfLife(
      name: '오렌지',
      fridgeDays: 21,
      freezerDays: 90,
      pantryDays: 7,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: bananas, refrigerator 3 days, freezer 2–3 months
    ShelfLife(
      name: '바나나',
      fridgeDays: 3,
      freezerDays: 75,
      pantryDays: 5,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: berries(strawberries), refrigerator 3–5 days
    ShelfLife(
      name: '딸기',
      fridgeDays: 4,
      freezerDays: 240,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: grapes, counter 1 day, refrigerator 1 week,
    // freezer 1 month
    ShelfLife(
      name: '포도',
      fridgeDays: 7,
      freezerDays: 30,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(멜론류, 절단 후 냉장 3~5일 상식 기준) 추정, 냉동 부적합
    ShelfLife(
      name: '수박',
      fridgeDays: 5,
      freezerDays: 1,
      pantryDays: 5,
      defaultUnit: '통',
    ),
    // 자료 없음 - 근연 품목(수박/멜론류) 기준 추정
    ShelfLife(
      name: '참외',
      fridgeDays: 5,
      freezerDays: 1,
      pantryDays: 5,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: stone fruits(peaches), refrigerator 3–5 days(익은 후)
    ShelfLife(
      name: '복숭아',
      fridgeDays: 4,
      freezerDays: 240,
      pantryDays: 3,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: blueberries, refrigerator 1–1.5 weeks
    ShelfLife(
      name: '블루베리',
      fridgeDays: 10,
      freezerDays: 240,
      pantryDays: 2,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: kiwi, refrigerator 4–6 weeks(미숙과 기준, 구매
    // 시점 고려해 중간값 채택)
    ShelfLife(
      name: '키위',
      fridgeDays: 28,
      freezerDays: 240,
      pantryDays: 5,
      defaultUnit: '개',
    ),
    // 자료 없음 - 근연 품목(citrus, USDA 2~3주) 기준 추정
    ShelfLife(
      name: '레몬',
      fridgeDays: 21,
      freezerDays: 90,
      pantryDays: 7,
      defaultUnit: '개',
    ),
    // 자료 없음(익음 정도에 따라 상이) - 익은 후 냉장 3~5일 상식 기준 추정
    ShelfLife(
      name: '아보카도',
      fridgeDays: 5,
      freezerDays: 150,
      pantryDays: 5,
      defaultUnit: '개',
    ),
    // 곡물 · 건식품
    // USDA FoodKeeper: white rice pantry 최대 5년 - 가정용 개봉 후
    // 품질 기준으로 보수적으로 채택
    ShelfLife(
      name: '쌀',
      fridgeDays: 180,
      freezerDays: 365,
      pantryDays: 180,
      defaultUnit: 'kg',
    ),
    // USDA FoodKeeper: whole-grain rice shelf life 6 months(지방 함량으로 백미보다 짧음)
    ShelfLife(
      name: '현미',
      fridgeDays: 90,
      freezerDays: 365,
      pantryDays: 90,
      defaultUnit: 'kg',
    ),
    // USDA FoodKeeper: flour, 원포장 6~8개월·밀폐용기 최대 2년(중간값 채택)
    ShelfLife(
      name: '밀가루',
      fridgeDays: 240,
      freezerDays: 365,
      pantryDays: 240,
      defaultUnit: 'g',
    ),
    // 자료 없음(식약처 빵류 미개봉 참고값 31일) - 가정 개봉 후 상식
    // 기준으로 보수적으로 추정
    ShelfLife(
      name: '식빵',
      fridgeDays: 5,
      freezerDays: 90,
      pantryDays: 3,
      defaultUnit: '봉',
    ),
    // 식약처 소비기한 참고값: 유탕면 207~333일(미개봉) - 가정 보관은
    // 더 보수적으로 채택, 냉동 부적합
    ShelfLife(
      name: '라면',
      fridgeDays: 150,
      freezerDays: 1,
      pantryDays: 150,
      defaultUnit: '개',
    ),
    // USDA FoodKeeper: dried pasta/noodles pantry 1~2년(하한 채택), 냉동 불필요
    ShelfLife(
      name: '국수',
      fridgeDays: 365,
      freezerDays: 1,
      pantryDays: 365,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: dried pasta pantry 1~2년(국수와 동일 근거)
    ShelfLife(
      name: '파스타면',
      fridgeDays: 365,
      freezerDays: 1,
      pantryDays: 365,
      defaultUnit: 'g',
    ),
    // 식약처 소비기한 참고값: 56일(미개봉, 실온/냉장 유통 기준) - 생떡
    // 특성상 가정에서는 냉장 단기 보관으로 보수적으로 채택
    ShelfLife(
      name: '떡',
      fridgeDays: 3,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 식약처 소비기한 참고값: 냉동만두 533일(미개봉) - 냉동 보관
    // 원칙 식품이라 냉장은 해동 후 기준, 냉동은 가정용 보수적으로 채택
    ShelfLife(
      name: '만두',
      fridgeDays: 2,
      freezerDays: 180,
      pantryDays: 1,
      defaultUnit: '개',
    ),
    // 자료 없음 - 건조 해조류, 밀봉 시 장기 보관 가능하나 가정
    // 개봉 후 기준으로 보수적으로 채택
    ShelfLife(
      name: '김',
      fridgeDays: 180,
      freezerDays: 365,
      pantryDays: 180,
      defaultUnit: '봉',
    ),
    // 자료 없음 - 김과 동일한 건조 해조류 로직으로 추정
    ShelfLife(
      name: '미역',
      fridgeDays: 180,
      freezerDays: 365,
      pantryDays: 180,
      defaultUnit: 'g',
    ),
    // USDA FoodKeeper: nuts opened, refrigerator 2~9개월 - 가정용 보수적으로 채택
    ShelfLife(
      name: '견과류',
      fridgeDays: 30,
      freezerDays: 240,
      pantryDays: 14,
      defaultUnit: 'g',
    ),
    // 두부 · 가공품
    // 식약처 소비기한 참고값: 23일(미개봉) - 개봉 후 물에 담가 냉장
    // 보관 시 가정용 안전 마진을 적용해 단축
    ShelfLife(
      name: '두부',
      fridgeDays: 5,
      freezerDays: 90,
      pantryDays: 1,
      defaultUnit: '모',
    ),
    // 자료 없음 - 근연 품목(두부, 식약처 23일 미개봉) 기준 개봉 후 추정
    ShelfLife(
      name: '유부',
      fridgeDays: 5,
      freezerDays: 60,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 자료 없음(식약처 미공개, 발효식품 특성상 유통기한을 안 매기는
    // 경우가 많음) - 품질 기준으로 보수적으로 채택, 냉동 비권장
    ShelfLife(
      name: '김치',
      fridgeDays: 60,
      freezerDays: 1,
      pantryDays: 14,
      defaultUnit: 'g',
    ),
    // 자료 없음 - 근연 품목(절임식품 일반, pH 낮은 절임류 특성상
    // 두부보다 길게) 기준 추정, 냉동 부적합
    ShelfLife(
      name: '단무지',
      fridgeDays: 30,
      freezerDays: 1,
      pantryDays: 7,
      defaultUnit: 'g',
    ),
    // 양념 · 소스
    // 자료 없음(식약처 장류 참고값 미공개) - 발효장류 특성상 상온
    // 안전 식품이라 보수적으로 추정, 냉동 불필요
    ShelfLife(
      name: '고추장',
      fridgeDays: 365,
      freezerDays: 1,
      pantryDays: 180,
      defaultUnit: 'g',
    ),
    // 자료 없음(식약처 장류 참고값 미공개) - 고추장과 동일 로직으로 추정
    ShelfLife(
      name: '된장',
      fridgeDays: 365,
      freezerDays: 1,
      pantryDays: 180,
      defaultUnit: 'g',
    ),
    // 자료 없음(식약처 참고값 미확인) - 염도 높은 발효 조미료로
    // 상온 안정성이 높아 보수적으로 추정
    ShelfLife(
      name: '간장',
      fridgeDays: 365,
      freezerDays: 1,
      pantryDays: 365,
      defaultUnit: 'mL',
    ),
    // 자료 없음(식약처 참고값 미확인) - 산도가 높아 미생물 번식이
    // 어려운 특성상 보수적으로 추정
    ShelfLife(
      name: '식초',
      fridgeDays: 365,
      freezerDays: 1,
      pantryDays: 365,
      defaultUnit: 'mL',
    ),
    // 자료 없음(식약처 "6개월 이상"까지만 확인, 구체 수치 미공개) -
    // 산패 위험을 고려해 보수적으로 채택
    ShelfLife(
      name: '참기름',
      fridgeDays: 180,
      freezerDays: 1,
      pantryDays: 180,
      defaultUnit: 'mL',
    ),
    // 자료 없음(식약처 참고값 미확인) - 참기름과 동일 로직, 산패 위험 고려
    ShelfLife(
      name: '식용유',
      fridgeDays: 180,
      freezerDays: 1,
      pantryDays: 180,
      defaultUnit: 'mL',
    ),
    // 식약처 소비기한 참고값: 231일(미개봉) - 개봉 후 업계 권장(2개월) 반영, 냉동 부적합
    ShelfLife(
      name: '마요네즈',
      fridgeDays: 60,
      freezerDays: 1,
      pantryDays: 1,
      defaultUnit: 'g',
    ),
    // 식약처 소비기한 참고값: 8개월~345일(미개봉) - 개봉 후 가정용
    // 보수적으로 채택, 냉동 부적합
    ShelfLife(
      name: '케첩',
      fridgeDays: 180,
      freezerDays: 1,
      pantryDays: 30,
      defaultUnit: 'g',
    ),
  ];
}
