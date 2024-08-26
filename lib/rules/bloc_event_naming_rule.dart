import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:rf_lint/models/rf_diagnostic_message.dart';
import 'package:rf_lint/rules/class_name_rule.dart';

class BlocEventClassNamingRule extends ClassNameRule {
  const BlocEventClassNamingRule()
      : super(
          code: const LintCode(
            name: 'bloc_event_naming_style',
            problemMessage:
                '''BLoc Event class should have the name of the form:
            ^(BLOC_CLASS_NAME)Event([A-Z][a-zA-Z0-9])+\$
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

      // if not a valid declared element, return
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
      final eventType = typeArguments[0];

      if (eventType.element is ClassElement) {
        final subclassElements = getSubclassElementList(
          element: eventType.element as ClassElement,
          regExp: RegExp(
            '^($blocClassName)Event([A-Z][a-zA-Z0-9])+\$',
          ),
        );

        if (subclassElements.isNotEmpty) {
          reporter.reportErrorForNode(
            code,
            typeAnnotations?[0] as AstNode,
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
          mMessage: "Fix Bloc event class name according to the rule.",
          mFilePath: unit.path,
          mOffset: unit.unit.offset,
          mLength: unit.unit.length,
        ),
      );
    }
    return messages;
  }
}
