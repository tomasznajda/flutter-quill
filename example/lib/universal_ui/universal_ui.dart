library universal_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;
import 'package:youtube_player_flutter_quill/youtube_player_flutter_quill.dart';

import '../widgets/responsive_widget.dart';
import 'fake_ui.dart' if (dart.library.html) 'real_ui.dart' as ui_instance;

class PlatformViewRegistryFix {
  void registerViewFactory(dynamic x, dynamic y) {
    if (kIsWeb) {
      ui_instance.PlatformViewRegistry.registerViewFactory(
        x,
        y,
      );
    }
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();

Widget defaultEmbedBuilderWeb(
  BuildContext context,
  QuillController controller,
  Embed node,
  bool readOnly,
  void Function(GlobalKey videoContainerKey)? onVideoInit,
) {
  switch (node.value.type) {
    case BlockEmbed.imageType:
      final imageUrl = node.value.data;
      if (isImageBase64(imageUrl)) {
        // TODO: handle imageUrl of base64
        return const SizedBox();
      }
      final size = MediaQuery.of(context).size;
      UniversalUI().platformViewRegistry.registerViewFactory(
          imageUrl, (viewId) => html.ImageElement()..src = imageUrl);
      return Padding(
        padding: EdgeInsets.only(
          right: ResponsiveWidget.isMediumScreen(context)
              ? size.width * 0.5
              : (ResponsiveWidget.isLargeScreen(context))
                  ? size.width * 0.75
                  : size.width * 0.2,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: HtmlElementView(
            viewType: imageUrl,
          ),
        ),
      );
    case BlockEmbed.videoType:
      final youtubeID = YoutubePlayer.convertUrlToId(node.value.data);
      var embedUrl = node.value.data;

      if (youtubeID != null) {
        embedUrl =
            'https://www.youtube.com/embed/${YoutubePlayer.convertUrlToId(node.value.data)}';
      }

      UniversalUI().platformViewRegistry.registerViewFactory(
          embedUrl,
          (id) => html.IFrameElement()
            ..width = MediaQuery.of(context).size.width.toString()
            ..height = MediaQuery.of(context).size.height.toString()
            ..src = embedUrl
            ..style.border = 'none');

      return SizedBox(
        height: 500,
        child: HtmlElementView(
          viewType: embedUrl,
        ),
      );
    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
        'embed builder of QuillEditor. You must pass your own builder function '
        'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}
