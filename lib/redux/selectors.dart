import '../entity/app_parameter.dart';
import '../entity/tv_show.dart';
import '../main.dart';

List<AppParameter> selectAppParameters() => store.state.appParameters;

String? selectParameterValueByKey(String key) {
  try {
    return store.state.appParameters.firstWhere((element) => element.getKey() == key).getValue();
  } catch (e) {
    return null;
  }
}

bool selectParameterValueByKeyAsBoolean(String key, {bool defaultValue = true}) {
  String? value = selectParameterValueByKey(key);

  if (value == null) {
    return defaultValue;
  }

  return value == "true";
}

List<TvShow> selectActiveTvShows() => store.state.tvShows.where((s) => !s.isArchived).toList();

List<TvShow> selectArchivedTvShows() => store.state.tvShows.where((s) => s.isArchived).toList();
