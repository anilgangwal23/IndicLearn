import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _HardcodedStringLinter();

class _HardcodedStringLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const NoHardcodedUiString(),
  ];
}

/// Flags string literals passed to widget parameters that display text.
///
/// Move the text to lib/l10n/app_en.arb and read it via AppLocalizations.
class NoHardcodedUiString extends DartLintRule {
  const NoHardcodedUiString() : super(code: _code);

  static const _code = LintCode(
    name: 'no_hardcoded_ui_string',
    problemMessage:
        'User-facing text must come from AppLocalizations (lib/l10n/app_en.arb), not a string literal.',
  );

  static const _textParameterNames = {
    'labelText',
    'hintText',
    'helperText',
    'errorText',
    'counterText',
    'tooltip',
    'semanticsLabel',
    'semanticLabel',
    'message',
    'accountActionLabel',
    'placeholder',
  };

  static const _textWidgetNames = {'Text', 'SelectableText', 'TextSpan'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (_isTestFile(resolver.path)) return;

    context.registry.addSimpleStringLiteral((node) {
      if (node.value.trim().isEmpty) return;
      _report(node.parent is AdjacentStrings ? node.parent! : node, reporter);
    });

    context.registry.addStringInterpolation((node) {
      _report(node, reporter);
    });
  }

  void _report(AstNode literal, ErrorReporter reporter) {
    if (_isUiText(literal)) reporter.atNode(literal, _code);
  }

  bool _isUiText(AstNode literal) {
    final parent = literal.parent;

    if (parent is NamedExpression) {
      return _textParameterNames.contains(parent.name.label.name);
    }

    if (parent is ArgumentList) {
      final call = parent.parent;
      if (call is InstanceCreationExpression &&
          _textWidgetNames.contains(call.constructorName.type.toSource()) &&
          parent.arguments.first == literal) {
        return true;
      }
    }

    return false;
  }

  static bool _isTestFile(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.contains('/test/') || normalized.contains('/tools/');
  }
}
