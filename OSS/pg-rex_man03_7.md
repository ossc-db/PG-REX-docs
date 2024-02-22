アンインストール
----------------

PG-REXをアンインストールするためには両ノードで作業をします。アンインストールの前にPG-REXが起動している場合は『PG-REXの停止』の手順に従って停止してください。必要なデータがある場合はバックアップを取得し、バックアップディレクトリから退避してください。

本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

(1) PostgreSQLをアンインストールします。


    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# rpm \-e postgresql12\-contrib\-12.2\-1PGDG.rhel8.x86_64]{custom-style="Verbatim Char"}\
  [# rpm \-e postgresql12\-server\-12.2\-1PGDG.rhel8.x86_64]{custom-style="Verbatim Char"}\
  [# rpm \-e postgresql12\-docs\-12.2\-1PGDG.rhel8.x86_64]{custom-style="Verbatim Char"}\
  [# rpm \-e postgresql12\-12.2\-1PGDG.rhel8.x86_64]{custom-style="Verbatim Char"}\
  [# rpm \-e postgresql12\-libs\-12.2\-1PGDG.rhel8.x86_64]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) DBクラスタディレクトリ配下のファイル、作成した環境変数のファイルおよびMD5暗号化パスワード認証の自動化ファイル(.pgpass)を削除します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# rm \-r /dbfp/pgdata/data/\*]{custom-style="Verbatim Char"}\
  [# rm /var/lib/pgsql/.bash_profile]{custom-style="Verbatim Char"}\
  [# rm /var/lib/pgsql/.pgpass]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) その他、作成した環境に合わせて以下の作業を行います。

    -   DBクラスタディレクトリのアンマウント
    -   WALディレクトリ配下のファイルの削除・アンマウント
    -   アーカイブディレクトリ配下のファイルの削除・アンマウント
    -   運用中に取得したDBクラスタのバックアップの削除

    ::: {custom-style="page-break"}
    　
    :::

(4) Pacemakerをアンインストールします。

::: {custom-style="First Paragraph"}
　
:::

既存のHAクラスタを破棄します。（いずれか1つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs cluster destroy \-\-all]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

ノードの認証を破棄します。（いずれか1つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs host deauth pgrex01 pgrex02]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

Pacemaker関連パッケージをアンインストールします。（2つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# yum erase pcs pacemaker fence\-agents\-all \-y]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

Pacemaker関連のファイルを削除します。（2つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# rm \-fr /var/lib/pcsd/ /var/lib/pacemaker /var/lib/corosync /var/log/pacemaker /var/log/cluster /etc/corosync /mnt/HighAvailability /etc/systemd/system/corosync.service /etc/sysconfig/pacemaker.rpmsave /etc/sysconfig/sbd.rpmsave]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

haclusterユーザおよび、haclientグループを削除します。（2つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# userdel hacluster]{custom-style="Verbatim Char"}\
  [# groupdel haclient]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

pm_extra_toolsをアンインストールします。（2つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# yum erase pm_extra_tools \-y]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(5) BIOSの設定でACPI Soft-Off機能を無効にした場合はBIOSでACPI Soft-Off機能を有効に戻します。 /etc/systemd/logind.confを修正した場合は、以下手順に従いlogind.confを修正し有効に戻します。

::: {custom-style="First Paragraph"}
　
:::

ACPI Soft-off機能を有効化するため、/etc/systemd/logind.confを以下の通り修正します。（2つのノードで実行）

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [HandlePowerKey=poweroff]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

systemd-logindサービスを再起動し、設定を反映させます。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# systemctl restart systemd-logind.service]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

ACPI Soft-Off機能が有効化されていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# loginctl show-user]{custom-style="Verbatim Char"}\
  [：(省略)]{custom-style="Verbatim Char"}\
  [HandlePowerKey=poweroff]{custom-style="Verbatim Char"}\
  [：(省略)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(6) PG-REX運用補助ツールをアンインストールします。

    RPMパッケージのアンインストールを行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# yum\ remove\ pg\-rex_operation_tools_script\-12\.2\-1\.el8\.noarch\.rpm\ IO_Tty\-1\.11\-1\.el8\.x86_64\.rpm\ Net_OpenSSH\-0\.62\-1\.el8\.x86_64\.rpm]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------
