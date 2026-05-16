import '../main.dart';
import '../redux/actions.dart';

abstract class StoreService {
  Future<void> loadAppParameters() async {
    await store.dispatch(LoadAppParametersAction());
  }
}
