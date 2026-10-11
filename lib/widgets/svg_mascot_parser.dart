import 'package:xml/xml.dart';

/// One independently renderable SVG layer.
class SvgMascotLayer {
  const SvgMascotLayer({
    required this.id,
    required this.svg,
  });

  final String id;
  final String svg;
}

/// Splits a mascot SVG into independently renderable top-level groups.
///
/// Contract:
/// - Use a 300 x 300 viewBox: `viewBox="0 0 300 300"`.
/// - Each animatable part must be a direct child `<g id="...">` of `<svg>`.
/// - Supported IDs are listed in [requiredLayerIds].
/// - Put shared SVG definitions (`<defs>`, `<style>`, etc.) at the SVG root.
/// - Keep artwork for each part inside its named group.
class SvgMascotParser {
  SvgMascotParser._();

  static const requiredLayerIds = <String>{
    'body',
    'left_leg',
    'right_leg',
    'left_hand',
    'right_hand',
    'left_eye',
    'right_eye',
    'left_eyebrow',
    'right_eyebrow',
  };

  static List<SvgMascotLayer> parse(String source) {
    final original = XmlDocument.parse(source);
    final root = original.rootElement;

    if (root.name.local != 'svg') {
      throw const FormatException('Mascot asset must have an <svg> root.');
    }

    final foundIds = root.children
        .whereType<XmlElement>()
        .where((element) => element.name.local == 'g')
        .map((element) => element.getAttribute('id'))
        .whereType<String>()
        .where(requiredLayerIds.contains)
        .toSet();

    final missing = requiredLayerIds.difference(foundIds);
    if (missing.isNotEmpty) {
      throw FormatException(
        'Mascot SVG is missing direct-child groups: ${missing.join(', ')}',
      );
    }

    // Preserve the source's top-level group order for correct layer stacking.
    final layerIds = root.children
        .whereType<XmlElement>()
        .where((element) => element.name.local == 'g')
        .map((element) => element.getAttribute('id'))
        .whereType<String>()
        .where(requiredLayerIds.contains)
        .toList();

    return layerIds.map((targetId) {
      final document = XmlDocument.parse(source);
      final svgRoot = document.rootElement;

      // Remove other animatable groups, retaining defs, styles, metadata,
      // and any non-animatable root-level nodes.
      final toRemove = svgRoot.children
          .whereType<XmlElement>()
          .where((element) {
            final id = element.getAttribute('id');
            return element.name.local == 'g' &&
                id != null &&
                requiredLayerIds.contains(id) &&
                id != targetId;
          })
          .toList();

      for (final node in toRemove) {
        svgRoot.children.remove(node);
      }

      return SvgMascotLayer(
        id: targetId,
        svg: document.toXmlString(),
      );
    }).toList(growable: false);
  }
}
