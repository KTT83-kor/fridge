abstract final class AppStrings {
  static const appTitle = '우리집 냉장고';

  static const emptyIngredients = '냉장고가 비어 있습니다';
  static const emptyIngredientsHint = '오른쪽 아래 버튼으로 재료를 담아 보세요';
  static const addIngredient = '재료 담기';
  static const loadIngredientsFailed = '재료를 불러오지 못했습니다';
  static const saveIngredientFailed = '재료를 저장하지 못했습니다';
  static const removeIngredientFailed = '재료를 삭제하지 못했습니다';
  static const retry = '다시 시도';
  static const removeIngredient = '재료 빼기';

  static const dDay = 'D-DAY';

  static const addIngredientTitle = '재료 담기';
  static const ingredientName = '재료 이름';
  static const ingredientNameHint = '예: 우유';
  static const ingredientNameRequired = '재료 이름을 입력해 주세요';
  static const ingredientAmount = '수량';
  static const ingredientAmountHint = '예: 1';
  static const ingredientAmountRequired = '0보다 큰 수량을 입력해 주세요';
  static const ingredientUnit = '단위';
  static const storagePlaceLabel = '보관 장소';
  static const purchasedAtLabel = '산 날짜';
  static const expiresAtLabel = '소진 기한';
  static const expiryFromTable = '보관기간 표에서 채웠습니다';
  static const expiryFromDefault = '표에 없어 기본값으로 채웠습니다';
  static const expiryManual = '직접 고른 날짜입니다';
  static const expiryResetToTable = '자동으로 되돌리기';
  static const save = '담기';
  static const defaultUnit = '개';
  static const ingredientSaved = '재료를 담았습니다';
  static const removedIngredient = '재료를 뺐습니다';

  static String daysFromPurchase(int days) => '산 날짜로부터 $days일';

  static const storageFridge = '냉장';
  static const storageFreezer = '냉동';
  static const storagePantry = '실온';

  static const freshnessExpired = '기한 지남';
  static const freshnessUrgent = '오늘내일';
  static const freshnessSoon = '곧 소진';
  static const freshnessFresh = '넉넉함';
}
