[^2]: PostgreSQL関連のツールの対応状況によって日本語が表示されないこともあります。

[^3]: 参照先：[<http://www.postgresql.jp/document/12/html/functions-admin.html>](http://www.postgresql.jp/document/12/html/functions-admin.html)

[^4]: 参照先：[<http://www.postgresql.jp/document/12/html/functions-admin.html>](http://www.postgresql.jp/document/12/html/functions-admin.html)

[^5]: 参照先：[<http://www.postgresql.jp/document/12/html/warm-standby.html#STANDBY-PLANNING>](http://www.postgresql.jp/document/12/html/warm-standby.html#STANDBY-PLANNING)

[^7]: 参照先：[<http://www.postgresql.jp/document/12/html/hot-standby.html#HOT-STANDBY-CONFLICT>](http://www.postgresql.jp/document/12/html/hot-standby.html#HOT-STANDBY-CONFLICT)

[^15]: リストアコマンドはpm\_pcsgen環境定義書に設定します。設定方法は『リソース（PostgreSQL）の設定』を参照してください。

[^16]: tcp\_keepalives\_idle、tcp\_keepalives\_interval、tcp\_keepalives\_countの設定を指します。

[^17]: アーカイブコマンドの設定は『postgresql.confの編集』を参照してください。

[^20]: 参照先: [<http://www.postgresql.jp/document/12/html/hot-standby.html#HOT-STANDBY-ADMIN>](http://www.postgresql.jp/document/12/html/hot-standby.html#HOT-STANDBY-ADMIN)

[^21]: 参照先：[<http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-BASE-BACKUP>](http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-BASE-BACKUP)

[^22]: バックアップ履歴ファイルは、拡張子が.backupのファイルを指します。  
[<http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-BASE-BACKUP>](http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-BASE-BACKUP)

[^23]: タイムライン履歴ファイルは、拡張子が.historyのファイルを指します。  
[<http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-TIMELINES>](http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-TIMELINES)

[^32]: バックアップ履歴ファイルは、拡張子が.backupのファイルを指します。  
[<http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-BASE-BACKUP>](http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-BASE-BACKUP)

[^33]: タイムライン履歴ファイルは、拡張子が.historyのファイルを指します。  
[<http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-TIMELINES>](http://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-TIMELINES)

[^37]: PostgreSQLのサーバログファイルの場所は設定により異なります。詳細は『環境定義書 \[PostgreSQL\]』を参照してください。

[^38]: レプリケーション受付用の仮想IPアドレスの設定

[^39]: 相手のノードのD-LANのIPアドレスの設定

[^40]: ダウンロードサイト：[<http://linux-ha.osdn.jp/wp/dl>](http://linux-ha.osdn.jp/wp/dl)

[^41]: インストールDVDがメディア挿入時に自動マウントされた場合は、一旦手動でアンマウントし、再度マウントしてください。

[^43]: [https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/proc_configuring-acpi-for-fence-devices-configuring-fencing](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/proc_configuring-acpi-for-fence-devices-configuring-fencing)

[^44]: logind.confを修正する手順は、デフォルトターゲットがmultiuser.targetの場合にのみ有効です。graphical.target等の他のデフォルトターゲットの場合は、Red Hat社の次のドキュメントを参照し てください。
[https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/using_the_desktop_environment_in_rhel_8/changing-behavior-when-pressing-the-powerbutton_customizing-gnome-desktop-features](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/using_the_desktop_environment_in_rhel_8/changing-behavior-when-pressing-the-powerbutton_customizing-gnome-desktop-features)

[^46]: リソース定義xmlファイル生成時にリソース定義用スクリプトファイル(PG-REX12_pm_pcsgen_env.sh)も生成されますが、本マニュアルでは利用しません。

[^47]: pcs statusでノード名との対応が表示されます。詳細は【ノード情報表示部】を参照してください。

[^48]: 以降はRHELと表記します。

[^49]: 以降はRHEL HA Add-Onと表記します。

[^50]: 本書の内容はPostgreSQL12.0で確認しました。

[^51]: RHEL HA Add-On 8.4に同梱されたものです。

[^52]: 本書の「PostgreSQLのバックアップ」の節にある操作例を参照