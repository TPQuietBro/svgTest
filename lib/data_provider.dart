import 'package:fage_render/Reader.dart';
import 'package:fage_render/ReaderPage.dart';
import 'package:fage_render/chapter_model.dart';
import 'package:flutter/services.dart';

const String holder_string = '\n \n';

class DataProvider {

  ChapterModel currentModel;
  ChapterModel nextModel;
  ChapterModel preModel;

  int get currentPageCount => _getCurrentPageCount();
  int get nextPageCount => _getNextPageCount();
  int get prePageCount => _getPrePageCount();

  bool get hasPre => preModel != null;
  bool get hasNext => nextModel != null;

  List get allPages => _getAllPages();

  _getCurrentPageCount(){
    return currentModel?.pageContents?.length ?? 0;
  }

  _getNextPageCount(){
    return nextModel?.pageContents?.length ?? 0;
  }

  _getPrePageCount(){
    return preModel?.pageContents?.length ?? 0;
  }

  _getAllPages(){
    List pages = [];
    pages.addAll(preModel?.pageContents??[]);
    pages.addAll(currentModel?.pageContents??[]);
    pages.addAll(nextModel?.pageContents??[]);
    if (pages.length == 0) {
      return [''];
    }
    return pages;
  }

  getCurrentPage(int chapterId) async{
    currentModel = ChapterModel();
    String content = await rootBundle.loadString('lib/chapter/chapter$chapterId.text');
    content = content.replaceAll('\n\n', holder_string);
    currentModel?.content = content;
    currentModel?.pageContents = await ReaderPage.getPages(ReaderUtil.paintSize(), content);
    updateChapterId(currentModel,chapterId);
  }

  getNextPage(int chapterId) async{
    nextModel = ChapterModel();
    String content = await rootBundle.loadString('lib/chapter/chapter$chapterId.text');
    content = content.replaceAll('\n\n', holder_string);
    nextModel.content = content;
    nextModel.pageContents = await ReaderPage.getPages(ReaderUtil.paintSize(), content);
    updateChapterId(nextModel,chapterId);
  }

  getPrePage(int chapterId) async{
    preModel = ChapterModel();
    String content = await rootBundle.loadString('lib/chapter/chapter$chapterId.text');
    content = content.replaceAll('\n\n', holder_string);
    preModel.content = content;
    preModel.pageContents = await ReaderPage.getPages(ReaderUtil.paintSize(), content);
    updateChapterId(preModel,chapterId);
  }

  swipeNextChapter(){
    this.preModel = this.currentModel;
    this.currentModel = this.nextModel;
    this.nextModel = null;
  }

  swipePreChapter(){
    this.nextModel = this.currentModel;
    this.currentModel = this.preModel;
    this.preModel = null;
  }

  updateChapterId(ChapterModel chapterModel,int chapterId){
    if (chapterModel == null || chapterId < 1) return;
    chapterModel.currentId = chapterId;
    if (chapterId == 1) {
      chapterModel.previousId = 0;
    } else {
      chapterModel.previousId = chapterId - 1;
    }
    chapterModel.nextId = chapterId + 1;
  }
}