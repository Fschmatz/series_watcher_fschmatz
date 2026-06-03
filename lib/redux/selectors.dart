import '../entity/app_parameter.dart';
import '../entity/tv_show.dart';
import 'app_state.dart';

List<AppParameter> selectAppParameters(AppState state) => state.appParameters;

String? selectParameterValueByKey(AppState state, String key) {
  try {
    return state.appParameters.firstWhere((element) => element.getKey() == key).getValue();
  } catch (e) {
    return null;
  }
}

bool selectParameterValueByKeyAsBoolean(AppState state, String key, {bool defaultValue = true}) {
  String? value = selectParameterValueByKey(state, key);

  if (value == null) {
    return defaultValue;
  }

  return value == "true";
}

List<TvShow> selectActiveTvShows(AppState state) => state.tvShows.where((s) => !s.isArchived).toList();

List<TvShow> selectArchivedTvShows(AppState state) => state.tvShows.where((s) => s.isArchived).toList();
