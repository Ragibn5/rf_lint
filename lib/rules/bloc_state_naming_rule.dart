import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:rf_lint/models/rf_diagnostic_message.dart';
import 'package:rf_lint/rules/class_name_rule.dart';

class BlocStateClassNamingRule extends ClassNameRule {
  const BlocStateClassNamingRule()
      : super(
          code: const LintCode(
            name: 'bloc_state_naming_style',
            problemMessage:
                '''BLoc State class should have the name of the form:
            ^(BLOC_CLASS_NAME)State(Initial|Loading|Loaded|Success|([A-Z][a-zA-Z0-9]+Error))*\$
            \nPlease check this and all of its sub-class declarations to
             make sure they all follow the naming convention.
            \nNote: 'BLOC_CLASS_NAME' is the name of the BLoC class.
            ''',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final element = node.declaredElement;
      if (element == null) return;

      // Check if the class extends Bloc<Event, State>
      final superclass = element.supertype;
      if (superclass == null || superclass.element.name != 'Bloc') return;

      // Check if it has exactly two type parameters
      final typeArguments = superclass.typeArguments;
      if (typeArguments.length != 2) return;

      final typeAnnotations =
          node.extendsClause?.superclass.typeArguments?.arguments;
      if (typeAnnotations != null && typeAnnotations.length != 2) return;

      final blocClassName = element.name;
      final stateType = typeArguments[1];

      if (stateType.element is ClassElement) {
        final subclassElements = getSubclassElementList(
          element: stateType.element as ClassElement,
          regExp: RegExp(
            '^($blocClassName)State(Initial|Loading|Loaded|Success|([A-Z][a-zA-Z0-9]+Error))*\$',
          ),
        );

        if (subclassElements.isNotEmpty) {
          reporter.reportErrorForNode(
            code,
            typeAnnotations?[1] as AstNode,
          );
        }
      }
    });
  }

  List<DiagnosticMessage>? _buildDiagnosticMessages(
    List<ParsedUnitResult> units,
  ) {
    List<DiagnosticMessage> messages = [];
    for (final unit in units) {
      messages.add(
        RfDiagnosticMessage(
          mMessage: "Fix Bloc state class name according to the rule.",
          mFilePath: unit.path,
          mOffset: unit.unit.offset,
          mLength: unit.unit.length,
        ),
      );
    }
    return messages;
  }
}
