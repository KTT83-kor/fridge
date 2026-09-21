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
  static const editIngredientTitle = '재료 수정';
  static const saveEdit = '수정';
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
  static const ingredientUpdated = '재료를 수정했습니다';
  static const removedIngredient = '재료를 뺐습니다';

  static String daysFromPurchase(int days) => '산 날짜로부터 $days일';

  static const quickAddTitle = '빠른 입력';
  static const addIngredientOneByOne = '하나씩 담기';
  static const quickAddHint = '한 줄에 하나씩 적어 주세요\n예: 우유 2L 냉장\n두부 1모';
  static const quickAddParse = '미리보기';
  static const quickAddEmpty = '적은 재료가 없습니다';
  static const quickAddReviewHint = '내용을 확인하고 필요하면 고친 뒤 담아 주세요';
  static const quickAddUnrecognizedAmount = '수량을 확인해 주세요';
  static const quickAddBack = '다시 쓰기';
  static const quickAddSaveAll = '모두 담기';
  static String quickAddSavedCount(int count) => '재료 $count개를 담았습니다';

  static const quickAddScanReceipt = '영수증으로 담기';
  static const quickAddScanProductPhoto = '사진으로 담기';
  static const quickAddScanning = '영수증을 읽고 있어요';
  static const quickAddScanningProductPhoto = '사진을 읽고 있어요';
  static const quickAddReceiptEmpty = '영수증에서 재료를 찾지 못했습니다';
  static const quickAddProductPhotoEmpty = '사진에서 재료를 찾지 못했습니다';
  static const quickAddReceiptFailed = '영수증을 읽지 못했습니다';
  static const quickAddReceiptOverloaded = '지금 몰려서 안 돼요. 잠시 후 다시 시도해 주세요';
  static const quickAddReceiptQuotaExceeded =
      '오늘 쓸 수 있는 횟수를 다 썼어요. 내일 다시 시도해 주세요';
  static const quickAddReceiptApiKeyMissing = 'GEMINI_API_KEY가 설정돼 있지 않습니다';
  static String quickAddReceiptFailedWithCode(int statusCode) =>
      '영수증을 읽지 못했습니다 (오류 코드 $statusCode)';

  static const storageFridge = '냉장';
  static const storageFreezer = '냉동';
  static const storagePantry = '실온';

  static const freshnessExpired = '기한 지남';
  static const freshnessUrgent = '오늘내일';
  static const freshnessSoon = '곧 소진';
  static const freshnessFresh = '넉넉함';

  static const menuSuggestionTitle = '메뉴 추천';
  static const menuSuggestionEmpty = '냉장고에 재료가 없어 추천할 수 없습니다';
  static const menuSuggestionLoading = '냉장고 속 재료로 메뉴를 고르고 있어요';
  static const menuSuggestionFailed = '메뉴를 추천받지 못했습니다';
  static const menuSuggestionOverloaded = '지금 몰려서 안 돼요. 잠시 후 다시 시도해 주세요';
  static const menuSuggestionQuotaExceeded =
      '오늘 쓸 수 있는 횟수를 다 썼어요. 내일 다시 시도해 주세요';
  static const menuSuggestionApiKeyMissing = 'GEMINI_API_KEY가 설정돼 있지 않습니다';
  static String menuSuggestionFailedWithCode(int statusCode) =>
      '메뉴를 추천받지 못했습니다 (오류 코드 $statusCode)';
  static const menuSuggestionUsedIngredients = '사용하는 재료';
  static const menuSuggestionRetry = '다시 추천받기';
  static const menuSuggestionRecipe = '레시피 보기';
}
