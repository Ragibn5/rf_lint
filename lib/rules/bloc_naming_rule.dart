import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:rf_lint/rules/class_name_rule.dart';

class BlocNamingRule extends ClassNameRule {
  const BlocNamingRule()
      : super(
          code: const LintCode(
            name: 'bloc_naming_style',
            problemMessage:
                "BLoc class does not follow the provided naming pattern.\n"
                "Please check if the class name matches the pattern defined "
                "in rf_lint_config.yaml.",
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final Map<String, dynamic> config = loadConfig();

    final blocNamePattern = config['bloc_name_pattern'];
    final blocNameRegex =
        blocNamePattern != null ? RegExp(blocNamePattern) : null;

    final blocEventNamePattern = config['bloc_event_name_pattern'];
    final blocEventNameRegex =
        blocEventNamePattern != null ? RegExp(blocEventNamePattern) : null;

    final blocStateNamePattern = config['bloc_state_name_pattern'];
    final blocStateNameRegex =
        blocStateNamePattern != null ? RegExp(blocStateNamePattern) : null;

    context.registry.addClassDeclaration((node) {
      final element = node.declaredElement;

      // if not a valid declared element, return.
      if (element == null) return;

      // check if the class is a bloc class
      final superclass = element.supertype;
      if (superclass == null || superclass.element.name != 'Bloc') return;

      // if bloc_name_pattern is not specified, return.
      if (blocNameRegex != null && blocNameRegex.hasMatch(element.name)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
