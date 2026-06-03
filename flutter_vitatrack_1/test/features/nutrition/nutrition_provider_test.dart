import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/services/firestore_service.dart';
import 'package:flutter_vitatrack_1/features/nutrition/data/datasources/firestore_nutrition_datasource.dart';
import 'package:flutter_vitatrack_1/features/nutrition/domain/entities/nutrition.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';

class FakeFirestoreService implements FirestoreService {
  @override
  get _firestore => throw UnimplementedError();

  @override
  Future<void> deleteDocument(String collection, String docId) async {}

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async => null;

  @override
  Future<List<Map<String, dynamic>>> getCollection(String collection) async => [];

  @override
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>?> streamDocument(String collection, String docId) => Stream.empty();

  @override
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {}
}

class FakeFirestoreNutritionDataSource extends FirestoreNutritionDataSource {
  Nutrition _currentNutrition = Nutrition(
    caloDaNap: 0,
    caloMucTieu: 2000,
    soLyNuoc: 0,
    lichSuBuaAn: [],
  );

  FakeFirestoreNutritionDataSource() : super(FakeFirestoreService());

  @override
  Future<Nutrition> getNutritionToday(String uid) async {
    return _currentNutrition;
  }

  @override
  Future<void> incrementWater(String uid) async {
    _currentNutrition = Nutrition(
      caloDaNap: _currentNutrition.caloDaNap,
      caloMucTieu: _currentNutrition.caloMucTieu,
      soLyNuoc: _currentNutrition.soLyNuoc + 1,
      lichSuBuaAn: _currentNutrition.lichSuBuaAn,
    );
  }

  @override
  Future<void> decrementWater(String uid) async {
    if (_currentNutrition.soLyNuoc > 0) {
      _currentNutrition = Nutrition(
        caloDaNap: _currentNutrition.caloDaNap,
        caloMucTieu: _currentNutrition.caloMucTieu,
        soLyNuoc: _currentNutrition.soLyNuoc - 1,
        lichSuBuaAn: _currentNutrition.lichSuBuaAn,
      );
    }
  }

  @override
  Future<void> addMeal(String uid, int calo, double protein, double carb, double fat) async {
    final newMeal = {
      'id': 'meal_id',
      'tenMonAn': 'Bữa ăn thêm',
      'calo': calo,
      'protein': protein,
      'carbs': carb,
      'fat': fat,
    };
    _currentNutrition = Nutrition(
      caloDaNap: _currentNutrition.caloDaNap + calo,
      caloMucTieu: _currentNutrition.caloMucTieu,
      soLyNuoc: _currentNutrition.soLyNuoc,
      lichSuBuaAn: [..._currentNutrition.lichSuBuaAn, newMeal],
    );
  }
}

void main() {
  late FakeFirestoreNutritionDataSource fakeDataSource;
  late ProviderContainer container;
  const testUid = 'user_123';

  setUp(() {
    fakeDataSource = FakeFirestoreNutritionDataSource();
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Khởi tạo NutritionNotifier với giá trị mặc định bằng 0', () async {
    final notifier = NutritionNotifier(fakeDataSource, testUid);
    expect(notifier.state.caloDaNap, 0);
    expect(notifier.state.soLyNuoc, 0);
    expect(notifier.state.lichSuBuaAn.length, 0);
  });

  test('load() cập nhật đúng trạng thái dinh dưỡng hiện tại', () async {
    final notifier = NutritionNotifier(fakeDataSource, testUid);
    
    // Tự động load() đã chạy khi khởi tạo, đợi microtask chạy xong
    await Future.delayed(Duration.zero);

    expect(notifier.state.caloMucTieu, 2000);
  });

  test('uongNuoc() tăng số ly nước uống thêm 1', () async {
    final notifier = NutritionNotifier(fakeDataSource, testUid);
    await Future.delayed(Duration.zero);

    await notifier.uongNuoc();

    expect(notifier.state.soLyNuoc, 1);
  });

  test('botNuoc() giảm số ly nước uống đi 1 nhưng không giảm dưới 0', () async {
    final notifier = NutritionNotifier(fakeDataSource, testUid);
    await Future.delayed(Duration.zero);

    // Giảm khi nước đang bằng 0 -> Vẫn bằng 0
    await notifier.botNuoc();
    expect(notifier.state.soLyNuoc, 0);

    // Tăng lên 2 rồi giảm đi 1 -> Bằng 1
    await notifier.uongNuoc();
    await notifier.uongNuoc();
    await notifier.botNuoc();
    expect(notifier.state.soLyNuoc, 1);
  });

  test('themMonAn() tăng calo nạp và thêm bữa ăn vào lịch sử', () async {
    final notifier = NutritionNotifier(fakeDataSource, testUid);
    await Future.delayed(Duration.zero);

    await notifier.themMonAn(500, 20.0, 50.0, 10.0);

    expect(notifier.state.caloDaNap, 500);
    expect(notifier.state.lichSuBuaAn.length, 1);
    expect(notifier.state.lichSuBuaAn.first['calo'], 500);
  });
}
