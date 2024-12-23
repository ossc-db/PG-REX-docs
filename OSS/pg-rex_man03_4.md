PostgreSQL {#sec:PostgreSQL}
----------

本節では、PostgreSQLのインストールおよび基本設定について説明します。

この節を単独で実施する場合は、その準備として『[@sec:インストール_pm](#sec:インストール_pm) [インストール](#sec:インストール_pm)』の(1)を参照して、RHELのインストールDVDをマウントしてリポジトリに登録してください。

PostgreSQLのインストール完了後は、『[@sec:インストール完了後作業_pm](#sec:インストール完了後作業_pm) [インストール完了後作業](#sec:インストール完了後作業_pm)』を参照して、準備前の状態に戻してください。

::: {custom-style="First Paragraph"}
　
:::

### PostgreSQLのインストール

『PostgreSQLドキュメント』を参考にpgrex01とpgrex02へPostgreSQLをインストールします。PG-REXで使用できるPostgreSQLのバージョンは17のみとなります。

本作業はrootユーザで行います。

PG-REXのインストールに必須のRPMパッケージを以下に示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [postgresql17\-libs\-17.2\-1PGDG.rhel9.x86\_64.rpm]{custom-style="Verbatim Char"}\
  [postgresql17\-17.2\-1PGDG.rhel9.x86\_64.rpm]{custom-style="Verbatim Char"}\
  [postgresql17\-server\-17.2\-1PGDG.rhel9.x86\_64.rpm]{custom-style="Verbatim Char"}\
  [postgresql17\-contrib\-17.2\-1PGDG.rhel9.x86\_64.rpm]{custom-style="Verbatim Char"}\
  [postgresql17\-docs\-17.2\-1PGDG.rhel9.x86\_64.rpm]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}\
  [※ PL/PerlやPL/Tclなどの各種言語インターフェイスが必要な場合は、それぞれに対応するパッケージをインストールしてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

PostgreSQLをRPMパッケージからインストールします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# dnf install postgresql17\-libs\-17.2\-1PGDG.rhel9.x86\_64.rpm postgresql17\-17.2\-1PGDG.rhel9.x86\_64.rpm postgresql17\-server\-17.2\-1PGDG.rhel9.x86\_64.rpm postgresql17\-contrib\-17.2\-1PGDG.rhel9.x86\_64.rpm postgresql17\-docs\-17.2\-1PGDG.rhel9.x86\_64.rpm]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

PostgreSQLのRPMパッケージをインストールすると「/usr/pgsql-17」にインストールされ、「postgres」というOSのユーザと、「postgres」というグループが作成されます。ただし、作成されたユーザにはパスワードの設定はされていません。また、同名のユーザまたはグループが存在する場合は、新規作成されません。

/var/lib/pgsqlのパーミッションは700に変更され、/var/lib/pgsql配下の全ファイルのオーナ、グループがpostgres、postgresに変更されます。

::: {custom-style="page-break"}
　
:::

PG-REXではpostgresユーザのuidを26、postgresグループのgidを26であることを前提としています。以下のコマンドを実行し、postgresユーザが規定のuid、gidで作成されていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# id postgres]{custom-style="Verbatim Char"}\
  [uid=26(postgres) gid=26(postgres) groups=26(postgres)]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

規定のuid、gidになっていない場合は、下記のようにuid、gidを変更してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# groupmod \-g 26 postgres]{custom-style="Verbatim Char"}\
  [# usermod \-u 26 postgres]{custom-style="Verbatim Char"}\
  [# usermod \-g 26 postgres]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

RPMのインストールにより新規でユーザが作成された場合は、パスワードを設定してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# passwd postgres]{custom-style="Verbatim Char"}\
  [ユーザー postgres のパスワードを変更。]{custom-style="Verbatim Char"}\
  [新しいパスワード:]{custom-style="Verbatim Char"}\
  [新しいパスワードを再入力してください:]{custom-style="Verbatim Char"}\
  [passwd: すべての認証トークンが正しく更新できました。]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### 環境変数の設定

pgrex01とpgrex02で/var/lib/pgsql/.bash\_profileに環境変数を設定します。

- [PATH]{custom-style="bold"} : PostgreSQLコマンドへのパスの追加
- [PGDATA]{custom-style="bold"} : DBクラスタのパスの設定

pgrex01とpgrex02で同じ設定値を使用してください。

本作業はpostgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

設定例を以下に示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [export PATH=/usr/pgsql\-17/bin:$PATH]{custom-style="red-bold"}\
  [export PGDATA=/dbfp/pgdata/data]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### DBクラスタ用ディレクトリの作成

pgrex01とpgrex02で、DBクラスタを格納するディレクトリとWALを格納するディレクトリ、アーカイブログを格納するディレクトリを以下の設定で作成します。

DBクラスタやWALを外付けストレージに配置する場合は、該当のディレクトリに外付けストレージの論理ディスクをマウントしてから実施します。

なお、ディレクトリが既に存在する場合は、ディレクトリを空にします。

本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
DBクラスタ用ディレクトリの設定
:::

  ----------------------------------------------------------------------------
  ディレクトリ      パス               所有者    グループ  権限
  ----------------- ------------------ --------- --------- -------------------
  DBクラスタ用      /dbfp/pgdata/data  postgres  postgres  700

  WAL用             /dbfp/pgwal/pg_wal postgres  postgres  700

  アーカイブログ用  /dbfp/pgarch/arc1  任意      任意      postgres ユーザが読み\
                                                            書き可能な権限

  ----------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### DBクラスタの初期化

pgrex01で、postgresユーザにてDBクラスタを初期化します。

本作業はpostgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [$ initdb \-D /dbfp/pgdata/data \-X /dbfp/pgwal/pg_wal \-\-encoding=UTF\-8 \-\-no\-locale \-\-data\-checksums]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

### postgresql.confの編集 {#sec:postgresql.confの編集}

pgrex01でpostgresql.confを編集します。PG-REXの動作に影響するPostgreSQLのパラメータの設定は本節で説明します。その他のパラメータの役割と設定については『PostgreSQLドキュメント』を参照してください。

本作業はpostgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

以下にパラメータの設定例を示します。個々の設定については後述の説明を参照してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [listen_addresses = \'\*\']{custom-style="Verbatim Char"}\
  [superuser_reserved_connections = 10]{custom-style="Verbatim Char"}\
  [password_encryption = scram-sha-256]{custom-style="Verbatim Char"}\
  [wal_level = replica]{custom-style="Verbatim Char"}\
  [synchronous_commit = on]{custom-style="Verbatim Char"}\
  [archive_mode = always]{custom-style="Verbatim Char"}\
  [archive_command = \'/bin/cp %p /dbfp/pgarch/arc1/%f\']{custom-style="Verbatim Char"}\
  [max_wal_senders = 10]{custom-style="Verbatim Char"}\
  [wal_keep_size = 512MB]{custom-style="Verbatim Char"}\
  [wal_sender_timeout = 20s]{custom-style="Verbatim Char"}\
  [max_replication_slots = 10]{custom-style="Verbatim Char"}\
  [hot_standby = on]{custom-style="Verbatim Char"}\
  [max_standby_archive_delay = \-1]{custom-style="Verbatim Char"}\
  [max_standby_streaming_delay = \-1]{custom-style="Verbatim Char"}\
  [hot_standby_feedback = on]{custom-style="Verbatim Char"}\
  [wal_receiver_timeout = 20s]{custom-style="Verbatim Char"}\
  [restart_after_crash = off]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

設定値を決定するにあたって、注意すべき点を以下に示します。

::: {custom-style="First Paragraph"}
　
:::

- [listen_addresses]{custom-style="bold"}

    PG-REXでは、StandbyからレプリケーションのためのIP接続を受け付けるため、そのアドレスを含むように設定する。

- [superuser_reserved_connections]{custom-style="bold"}

    緊急用に余裕を持った値を設定しておく。10を推奨する。

- [password_encryption]{custom-style="bold"}

    pg_hba.confのMETHODと合わせる必要がある。

- [wal_level]{custom-style="bold"}

    logicalを設定することも可能。

- [synchronous_commit]{custom-style="bold"}

    本マニュアルではレプリケーションの信頼性を重視するため、onを推奨する。remote\_writeを設定した場合、故障発生時にデータを損失する可能性がある。remote\_applyを設定した場合、on設定時と同様の信頼性となるが、トランザクションの応答時間が長くなる。

- [archive_mode]{custom-style="bold"}

    設定はalways必須。

- [archive_command]{custom-style="bold"}

    WALファイルを圧縮して保存したい場合のコマンド設定例を以下に示す。

        '/bin/gzip -c %p > /dbfp/pgarch/arc1/%f.gz'

    ※ gzipを使用する場合は、後述するリストアコマンド[^15]にもgzipを使用すること。

- [max_wal_senders]{custom-style="bold"}

    PG-REXでは、レプリケーション機能を利用するため、1以上を設定する必要がある。ただし、pg\_basebackupによる運用中のバックアップ取得など、Standby以外からの接続に備え、余裕を持たせて設定することを推奨する。

- [wal_keep_size]{custom-style="bold"}

    以下の点を考慮すること。

    - 設定値が小さい場合、レプリケーション接続が一時的に切断されたときに、Standbyに転送されていないWALファイルがPrimaryから削除される可能性が高まる。WALファイルが削除されると、レプリケーションの再接続が不可能となる。

- [wal_sender_timeout]{custom-style="bold"}

    Standbyの故障や両ノード間の通信断をPrimaryがすぐに検知できるように、タイムアウトを有効にすることを推奨する。postgresql.confで設定するTCP keepaliveに関する設定[^16] だけでは、検知に時間がかかることがあり、異常時のダウンタイムが長くなることがある。ただし、設定値が小さすぎると誤検知によりStandbyが切り離されることがあるため、設定値は事前検証等をして注意して決めること。

- [max_replication_slots]{custom-style="bold"}

    pg\_basebackupによるバックアップ取得などに備え、余裕を持たせて設定することを推奨する。

- [hot_standby]{custom-style="bold"}

    設定はon必須。

- [max_standby_archive_delay]{custom-style="bold"}

    PG-REXでは、Standbyの監視クエリがキャンセルされるのを回避するために、-1(キャンセルを無効)を設定する。

- [max_standby_streaming_delay]{custom-style="bold"}

    PG-REXでは、Standbyの監視クエリがキャンセルされるのを回避するために、-1(キャンセルを無効)を設定する。

- [hot_standby_feedback]{custom-style="bold"}

    設定はon必須。

- [wal_receiver_timeout]{custom-style="bold"}

    wal_sender_timeoutと同程度に揃える必要がある。

- [restart_after_crash]{custom-style="bold"}

    PG-REX運用中にPostgreSQLが自動的に再起動すると、Pacemakerによる状態管理の整合性が崩れるため、offを設定しなければならない。

::: {custom-style="First Paragraph"}
　
:::

PG-REXでは自動的に必要な設定を行うため、ユーザは以下のパラメータを設定してはいけません。

- [primary_conninfo]{custom-style="bold"}

- [recovery_target_timeline]{custom-style="bold"}

- [restore_command]{custom-style="bold"}

- [synchronous_standby_names]{custom-style="bold"}

::: {custom-style="page-break"}
　
:::

### レプリケーションユーザの作成 {#sec:レプリケーションユーザの作成}

pgrex01で、PostgreSQLにレプリケーションのためのデータベースユーザを作成します。

本作業はpostgresユーザで行います。

データベースユーザ名とパスワードは適宜変更してください。

::: {custom-style="First Paragraph"}
　
:::

(1) PostgreSQLを一度起動します。

	::: {custom-style="First Paragraph"}
	　
	:::

  ------------------------------------------------------------------------
  [$ pg_ctl start]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) CREATE ROLEコマンドでレプリケーションユーザを作成します。

	::: {custom-style="First Paragraph"}
	　
	:::

  ------------------------------------------------------------------------
  [$ psql \-c \"CREATE ROLE]{custom-style="Verbatim Char"} [repuser]{custom-style="italic"} [REPLICATION LOGIN PASSWORD \']{custom-style="Verbatim Char"}[reppasswd]{custom-style="italic"}[\'\"]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) PostgreSQLを停止します。

	::: {custom-style="First Paragraph"}
	　
	:::

  ------------------------------------------------------------------------
  [$ pg_ctl stop]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

### pg\_hba.confの編集

pgrex01のpg\_hba.confを編集して、PG-REXを構成するのに必要な設定を行います。

本作業はpostgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

レプリケーション接続の設定については、pgrex02でも同じファイルを使用するため、両ノードのD-LANアドレスから接続を許可するように記述します。

レプリケーション接続以外の設定については『PostgreSQLドキュメント』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

以下に、このマニュアルで想定している構成での記述例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# TYPE DATABASE\ \ \ \ USER\ \ \ \ ADDRESS\ \ \ \ \ \ \ \ METHOD]{custom-style="Verbatim Char"}\
  [host\ \ \ replication\ ]{custom-style="Verbatim Char"}[repuser]{custom-style="italic"}[\ 192.168.2.1/32 scram-sha-256]{custom-style="Verbatim Char"}\
  [host\ \ \ replication\ ]{custom-style="Verbatim Char"}[repuser]{custom-style="italic"}[\ 192.168.2.2/32 scram-sha-256]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### パスワードファイルの作成

PG-REX構成で使用するパスワードファイルを作成します。

本作業はpostgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

pgrex01とpgrex02それぞれのpostgresユーザのホームディレクトリに、600の権限でパスワードファイル.pgpassを作成します。
PG-REXのレプリケーション接続および、PG-REX運用補助ツールで利用するため、レプリケーション受付用の仮想IPアドレス、および相手のノードのD-LANのIPアドレスについて記述します。

::: {custom-style="First Paragraph"}
　
:::

以下に、このマニュアルで想定している構成を前提とした記述例を示します。各フィールドの詳細な説明については『PostgreSQLドキュメント』を参照してください。


::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# hostname:port:database:username:password]{custom-style="Verbatim Char"}\
  [192.168.2.3:5432:replication:repuser:reppasswd]{custom-style="Verbatim Char"} [^38] \
  [192.168.2.2:5432:replication:repuser:reppasswd]{custom-style="Verbatim Char"} [^39]

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

