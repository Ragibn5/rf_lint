import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:rf_lint/rules/bloc_event_naming_rule.dart';
import 'package:rf_lint/rules/bloc_naming_rule.dart';
import 'package:rf_lint/rules/bloc_state_naming_rule.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => _RfLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _RfLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const BlocNamingRule(),
        const BlocEventClassNamingRule(),
        const BlocStateClassNamingRule(),
      ];
}
