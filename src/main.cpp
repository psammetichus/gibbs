#include <QtWidgets>
#include "mainwindow.h"


MainWindow::MainWindow()
{
  setCentralWidget(mywidget);
  createActions();
  createStatusBar();
  readSettings();
  connect(mywidget->document(), &EEGWidget::contentsChanged, this, &MainWindow::documentWasModified);

}


