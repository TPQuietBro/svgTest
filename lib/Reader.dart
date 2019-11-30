import 'dart:io';
import 'dart:ui';
import 'package:fage_render/data_provider.dart';
import 'package:fage_render/local_storage.dart';
import 'package:fage_render/vertical_view.dart';
import 'package:flutter/material.dart';

const String reader_page = 'reader_page';
const String reader_chapterId = 'reader_chapterId';
const int chapter_count = 8;

class ReaderWidget extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ReaderWidget> {
  bool _isVertical = true;
  ScrollController scrollController;
  PageController pageController;
  int _currentPage = 0;
  DataProvider dataProvider;

  int chapter = 1;

  int recordPage = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    dataProvider = DataProvider();
    pageController = PageController(initialPage: _currentPage);
    pageController.addListener(_onScroll);

    initContent();
    
  }

  initContent() async{
    var page = await LocalStorage.get(reader_page);
    var recordChapterId = await LocalStorage.get(reader_chapterId);
    if (page == null || recordChapterId == null) {
      await getCurrentContent(chapter);
      initNextContent(chapter + 1);
    } else {
      recordPage = int.parse(page);
      int curId = int.parse(recordChapterId);
      await getCurrentContent(curId);
      if (curId > 1) initPreContent(curId - 1);
      if (curId < chapter_count) initNextContent(curId + 1);
    }
  }

  initPreContent(int chapterId) async{
    await this.dataProvider.getPrePage(chapterId);
    reloadData();
    initPostion();
  }

  initNextContent(int chapterId) async{
    await this.dataProvider.getNextPage(chapterId);
    reloadData();
  }

  initPostion(){
    if (!_isVertical) {
      pageController.jumpToPage(this.dataProvider.prePageCount + recordPage);
    }
  }

  getCurrentContent(int chapterId) async {
    await dataProvider.getCurrentPage(chapterId);
    print('get current chapter');
    reloadData();
    initPostion();
  }

  getNextContent(int chapterId) async {
    if (chapterId > chapter_count) {
      reloadData();
      return;
    }
    await dataProvider.getNextPage(chapterId);
    print('get next chapter');
    reloadData();
  }

  getPreContent(int chapterId) async {
    if (chapterId < 1) {
      reloadData();
      return;
    }
    
    await dataProvider.getPrePage(chapterId);
    print('get pre chapter');
    pageController.jumpToPage(
        dataProvider.prePageCount + dataProvider.currentPageCount - 1);
    reloadData();
  }

  pageCount() {
    return dataProvider.allPages.length;
  }

  _onScroll() {
    var index = pageController.offset / Screen.width;

    var nextPageIndex =
        dataProvider.currentPageCount + dataProvider.prePageCount;

    if (index >= nextPageIndex) {
      print('next page');
      dataProvider.swipeNextChapter();
      _currentPage = 0;
      pageController.jumpToPage(dataProvider.prePageCount);
      getNextContent(this.dataProvider.currentModel.nextId);
    } else if (dataProvider.hasPre && index <= dataProvider.prePageCount - 1) {
      print('pre page');
      dataProvider.swipePreChapter();
      _currentPage = this.dataProvider.currentPageCount - 1;
      pageController.jumpToPage(dataProvider.currentPageCount - 1);
      getPreContent(this.dataProvider.currentModel.previousId);
    }
  }

  _onPageChanged(index) async{
    print('index = $index');
    int currentPage = index - (dataProvider.prePageCount);
    print('currentPage = $currentPage');
    if (currentPage >= 0 && currentPage < dataProvider.currentPageCount) {
      await LocalStorage.set(reader_page, currentPage.toString());
      await LocalStorage.set(reader_chapterId, this.dataProvider.currentModel.currentId.toString());
      setState(() {
        _currentPage = currentPage;
      });
    }
  }

  reloadData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            _isVertical
                ? VerticalView(dataProvider: this.dataProvider,)
                : PageView.builder(
                    onPageChanged: _onPageChanged,
                    scrollDirection: Axis.horizontal,
                    itemCount: pageCount(),
                    controller: pageController,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: ReaderUtil.readerTopMargin,
                            bottom: Screen.bottomMargin),
                        width: ReaderUtil.paintSize().width,
                        height: ReaderUtil.paintSize().height,
                        color: Colors.white,
                        child: Text.rich(
                          TextSpan(
                              text: dataProvider.allPages[index],
                              style: ReaderUtil.textStyle()),
                        ),
                      );
                    },
                  ),
            Positioned(
              top: 30,
              child: FlatButton(
                onPressed: () {
                  _isVertical = !_isVertical;
                  reloadData();
                },
                child: Text('change'),
              ),
            ),
            Positioned(
              bottom: Screen.bottomMargin,
              right: 16,
              child: Text(
                  '${_currentPage + 1}/${dataProvider?.currentModel?.pageContents?.length??0}'),
            )
          ],
        ));
  }
}

class Screen {
  static double get width => _getWidth();
  static double get height => _getHeight();
  static double get topMargin => _getTopMargin();
  static double get bottomMargin => _getBottomMargin();
  static double get statusBarHeight => _getStatusBarHeight();

  static _getWidth() {
    return MediaQueryData.fromWindow(window).size.width;
  }

  static _getHeight() {
    return MediaQueryData.fromWindow(window).size.height;
  }

  static _getTopMargin() {
    return MediaQueryData.fromWindow(window).padding.top;
  }

  static _getBottomMargin() {
    return MediaQueryData.fromWindow(window).padding.bottom;
  }

  static _getStatusBarHeight() {
    return Platform.isIOS ? 20.0 : 20.0;
  }
}

class ReaderUtil {
  static double margin = 24;
  static double readerTopMargin = Screen.topMargin + margin;
  static double readerBottomMargin = Screen.bottomMargin + margin;

  /// 渲染高度
  static double contentHeight() {
    double screenHeight = Screen.height;
    return screenHeight - (readerTopMargin + readerBottomMargin);
  }

  static textStyle() {
    return TextStyle(
        fontSize: 20, 
        letterSpacing: -0.49, 
        height: 1.5, 
        wordSpacing: -0.5);
  }

  static Size paintSize() {
    double lrMargin = 16;
    ParagraphBuilder(ParagraphStyle());
    return Size(Screen.width - lrMargin * 2, ReaderUtil.contentHeight());
  }
}
