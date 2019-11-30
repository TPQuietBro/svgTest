import 'package:fage_render/Reader.dart';
import 'package:fage_render/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerticalView extends StatefulWidget {
  final DataProvider dataProvider;
  VerticalView({this.dataProvider});
  @override
  VerticalViewState createState() => VerticalViewState();
}

class VerticalViewState extends State<VerticalView> {
  ScrollController scrollController;
  double maxOffset = 0;
  bool isLoading = false;
  String veticalContent = '';

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
  }

  onScroll() {
    if (scrollController.offset >= maxOffset && isLoading == false) {
      isLoading = true;
      getNextContent(widget.dataProvider.currentModel.nextId);
    } else if (scrollController.offset <= 0  && isLoading == false) {
      isLoading = true;
      getPreContent(widget.dataProvider.currentModel.previousId);
    }
  }

  getNextContent(int chapterId) async {
    if (chapterId > chapter_count) {
      Fluttertoast.showToast(msg: '已经是最后一页了');
      Future.delayed(Duration(milliseconds: 1000), () {
        isLoading = false;
      });
      return;
    }

    widget.dataProvider.swipeNextChapter();

    await widget.dataProvider.getNextPage(chapterId);

    delay(300, () {
      isLoading = false;
      reloadNextContent();

      print('get next chapter');
      reloadData();
    });
  }

  getPreContent(int chapterId) async {
    if (chapterId < 1) {
      Fluttertoast.showToast(msg: '已经是第一页了');
      Future.delayed(Duration(milliseconds: 1000), () {
        isLoading = false;
      });
      return;
    }
    widget.dataProvider.swipePreChapter();

    await widget.dataProvider.getPrePage(chapterId);
    delay(300, () {
      isLoading = false;
      reloadPreContent();

      print('get pre chapter');
      reloadData();
    });
  }

  delay(int ms, Function onDo) {
    Future.delayed(Duration(milliseconds: ms), onDo);
  }

  reloadData() {
    setState(() {});
  }

  reloadPreContent() {
    String content = widget.dataProvider.currentModel.content;
    if (widget.dataProvider.preModel != null) {
      content = widget.dataProvider.preModel.content + '\n \n' + content;
    }
    veticalContent = content;
    // scrollController.jumpTo(contentHeight(widget.dataProvider.currentModel.content));
    reloadData();
  }

  reloadNextContent() {
    String content = widget.dataProvider.currentModel.content;
    if (widget.dataProvider.nextModel != null) {
      content = content + '\n \n' + widget.dataProvider.nextModel.content;
    }
    veticalContent = content;
    reloadData();
  }

  double contentHeight(content){
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: content, 
        style: ReaderUtil.textStyle()
        ),
      textDirection: TextDirection.ltr
    );
    painter.layout(maxWidth:ReaderUtil.paintSize().width);
    return painter.height;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (ScrollNotification notification) {
          maxOffset = notification.metrics.maxScrollExtent;
          return true;
        },
        child: Scrollbar(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: scrollController,
                child: Container(
                  width: ReaderUtil.paintSize().width,
                  // height: ReaderUtil.paintSize().height,
                  margin: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: ReaderUtil.readerTopMargin,
                      bottom: Screen.bottomMargin),
                  child: Text.rich(
                    TextSpan(
                        text: this.veticalContent.length > 0
                            ? this.veticalContent
                            : widget?.dataProvider?.currentModel?.content ?? '',
                        style: ReaderUtil.textStyle()),
                  ),
                ))));
  }
}
