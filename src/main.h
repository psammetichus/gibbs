#include <QtWidgets>
#include "main.h"


class MainWindow : public QMainWindow
{
  Q_OBJECT

  public:
    MainWindow();

  protected:
    void closeEvent(QCloseEvent *event) override;

  private slots:
    void open();
    bool save();

  private:
    QString &filename;
};
