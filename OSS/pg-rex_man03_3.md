Pacemaker
---------

本節では、Pacemakerのインストールおよび基本設定について説明します。

本節の作業は、rootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

### 事前作業

Pacemakerをインストールする前に、OSの確認、RHELのインストールDVD、RHEL HA Add-Onの ISOイメージ、及びpm_extra_toolsの準備をします。

::: {custom-style="First Paragraph"}
　
:::

【OSの確認】

::: {custom-style="First Paragraph"}
　
:::

   インストールしたOSのバージョンについて、/etc/redhat-releaseの内容を確認します。以下の結果表示の斜体で記載しているバージョンを確認してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# cat /etc/redhat-release]{custom-style="Verbatim Char"}\
  [Red Hat Enterprise Linux release [9.4]{custom-style="italic"} (Plow)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【pm_extra_toolsの取得】

::: {custom-style="First Paragraph"}
　
:::

ダウンロードサイト[^40]より、RPMパッケージを入手します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [pm_extra_tools-1.6-1.el9.noarch.rpm]{custom-style="Verbatim Char"}\
  \
  [※ ダウンロードサイトにて、使用するRHELのバージョンに適合するパッケージを選んでください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### インストール {#sec:インストール_pm}

『Pacemaker関連サイト』を参考にpgrex01とpgrex02へPacemakerをインストールします。

(1) mountコマンドでRHELのインストールDVDを/mediaにマウントします[^41]。

::: {custom-style="First Paragraph"}
	　
:::

  ------------------------------------------------------------------------
  [# mount -o ro /dev/sr0 /media]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) /mnt/HighAvailabilityを作成し、mountコマンドでRHEL HA Add-OnのISOイメージをマウント します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# mkdir /mnt/HighAvailability]{custom-style="Verbatim Char"}\
  [# mount -o ro /var/tmp/rhel\-highavailability\-9\.4\-x86_64-dvd.iso /mnt/HighAvailability]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) /media配下、及び/mnt/HighAvailability配下をdnfコマンドで参照されるリポジトリに追加する 設定を行います。

::: {custom-style="First Paragraph"}
　
:::

/etc/yum.repos.d配下にrheldvd.repoを新規に作成し、以下の内容を記述します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [\[BaseOS\]]{custom-style="Verbatim Char"} \
  [name=Red Hat Enterprise Linux $releasever \- $basearch \- BaseOS]{custom-style="Verbatim Char"}\
  [baseurl=file:///media/BaseOS]{custom-style="Verbatim Char"}\
  [enabled=1]{custom-style="Verbatim Char"}\
  [gpgcheck=1]{custom-style="Verbatim Char"}\
  [gpgkey=file:///etc/pki/rpm-gpg/RPM\-GPG\-KEY\-redhat\-release]{custom-style="Verbatim Char"}\
  \
  [\[AppStream\]]{custom-style="Verbatim Char"}\
  [name=Red Hat Enterprise Linux $releasever \- $basearch \- AppStream]{custom-style="Verbatim Char"}\
  [baseurl=file:///media/AppStream]{custom-style="Verbatim Char"}\
  [enabled=1]{custom-style="Verbatim Char"}\
  [gpgcheck=1]{custom-style="Verbatim Char"}\
  [gpgkey=file:///etc/pki/rpm\-gpg/RPM\-GPG\-KEY\-redhat\-release]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

/etc/yum.repos.d配下にrhel-ha.repoを新規に作成し、以下の内容を記述します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [\[HighAvailability\]]{custom-style="Verbatim Char"}\
  [name=Red Hat Enterprise Linux $releasever \- $basearch \- HighAvailability]{custom-style="Verbatim Char"}\
  [baseurl=file:///mnt/HighAvailability]{custom-style="Verbatim Char"}\
  [enabled=1]{custom-style="Verbatim Char"}\
  [gpgcheck=1]{custom-style="Verbatim Char"}\
  [gpgkey=file:///etc/pki/rpm\-gpg/RPM\-GPG\-KEY\-redhat\-release]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(4) dnfのキャッシュをクリアします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# dnf clean all]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(5) Pacemakerをインストールします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# dnf install pcs pacemaker fence\-agents\-all \-y]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(6) pm_extra_toolsをインストールします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# dnf install pm_extra_tools\-1\.6\-1.el9.noarch.rpm \-y]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### インストール完了後作業 {#sec:インストール完了後作業_pm}

(1) この後、PostgreSQLおよび運用補助ツールのインストールを実行しない場合、dnfコマンドの参照先として追加した/media配下、及び/mnt/HighAvailability配下への参照を無効化します。  
※ 引き続きPostgreSQLおよび運用補助ツールのインストールを実行する場合は、それらを実施した後に、この節での操作を実施します。

::: {custom-style="First Paragraph"}
　
:::

/etc/yum.repos.d/rheldvd.repoを編集します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [\[BaseOS\]]{custom-style="Verbatim Char"} \
  [name=Red Hat Enterprise Linux $releasever \- $basearch \- BaseOS]{custom-style="Verbatim Char"}\
  [baseurl=file:///media/BaseOS]{custom-style="Verbatim Char"}\
  [enabled=]{custom-style="Verbatim Char"}[0]{custom-style="red-bold"}\
  [gpgcheck=1]{custom-style="Verbatim Char"}\
  [gpgkey=file:///etc/pki/rpm-gpg/RPM\-GPG\-KEY\-redhat\-release]{custom-style="Verbatim Char"}\
  \
  [\[AppStream\]]{custom-style="Verbatim Char"}\
  [name=Red Hat Enterprise Linux $releasever \- $basearch \- AppStream]{custom-style="Verbatim Char"}\
  [baseurl=file:///media/AppStream]{custom-style="Verbatim Char"}\
  [enabled=]{custom-style="Verbatim Char"}[0]{custom-style="red-bold"}\
  [gpgcheck=1]{custom-style="Verbatim Char"}\
  [gpgkey=file:///etc/pki/rpm\-gpg/RPM\-GPG\-KEY\-redhat\-release]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

/etc/yum.repos.d/rhel-ha.repoを編集します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [\[HighAvailability\]]{custom-style="Verbatim Char"}\
  [name=Red Hat Enterprise Linux $releasever \- $basearch \- HighAvailability]{custom-style="Verbatim Char"}\
  [baseurl=file:///mnt/HighAvailability]{custom-style="Verbatim Char"}\
  [enabled=]{custom-style="Verbatim Char"}[0]{custom-style="red-bold"}\
  [gpgcheck=1]{custom-style="Verbatim Char"}\
  [gpgkey=file:///etc/pki/rpm\-gpg/RPM\-GPG\-KEY\-redhat\-release]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------


::: {custom-style="First Paragraph"}
　
:::

(2)  umountコマンドでRHELのインストールDVD、RHEL HA Add-OnのISOイメージをアンマウン トします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# umount /media]{custom-style="Verbatim Char"}\
  [# umount /mnt/HighAvailability]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### HAクラスタ構築

本章では、HAクラスタ構築の方法について記述しています。 HAクラスタ構築の際には、Pacemakerのインストールが完了している必要があります。

::: {custom-style="First Paragraph"}
　
:::

(1) pcsdサービスを起動し、自動起動を有効にします。(2つのノードで実行)

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# systemctl start pcsd.service]{custom-style="Verbatim Char"}\
  [# systemctl enable pcsd.service]{custom-style="Verbatim Char"}\
  [# systemctl is-enabled pcsd.service]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) haclusterユーザのパスワードを設定します。(2つのノードで実行)

  ------------------------------------------------------------------------
  [# passwd hacluster]{custom-style="Verbatim Char"}\
  [ユーザー hacluster のパスワードを変更。]{custom-style="Verbatim Char"}\
  [新しいパスワード:]{custom-style="Verbatim Char"}\
  [新しいパスワードを再入力してください:]{custom-style="Verbatim Char"}\
  [passwd: すべての認証トークンが正しく更新できました。]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) 各ノードのホスト名、管理用LANのIPアドレスを指定し、ノードの認証を行います。(いずれか１つのノードで実行)\
認証の際はユーザ名にhacluster、パスワードに前項で設定したhaclusterのパスワードを入力してください。
    
::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs host auth pgrex01 addr=172.20.144.41 pgrex02 addr=172.20.144.42]{custom-style="Verbatim Char"}\
  [Username:\ ]{custom-style="Verbatim Char"}[hacluster]{custom-style="red-bold"}\
  [Password:]{custom-style="Verbatim Char"}\
  [pgrex01: Authorized]{custom-style="red-bold"}\
  [pgrex02: Authorized]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(4) Pacemaker設定ファイルを変更します。(2つのノードで実行)

::: {custom-style="First Paragraph"}
　
:::

/etc/sysconfig/pacemakerのPCMK_fail_fastのコメントアウトを外し、以下の通り編集します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [： (省略)]{custom-style="Verbatim Char"}\
  [PCMK_fail_fast=yes]{custom-style="red-bold"}\
  [： (省略)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

### ACPI Soft-Off機能の無効化

IPMI STONITH機能ではIPMIにより電源操作を実施しますが、その際にノードを即時に停止させる ためにACPI Soft-Off機能を無効にする必要があります。 
Red Hat社のドキュメント[^43]を参照し、ACPI Soft-Off機能を無効にしてください。\
BIOSの設定でACPI Soft-Off機能を無効にできるか確認し、BIOSでACPI Soft-Off機能を無効にでき ない場合は、以下手順に従いlogind.confを編集し無効にします[^44]。

::: {custom-style="First Paragraph"}
　
:::

(1) /etc/systemd/logind.confを以下の通り編集します。

  ------------------------------------------------------------------------
  [HandlePowerKey=ignore]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) systemd-logindサービスを再起動し、設定を反映させます。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# systemctl restart systemd-logind.service]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) ACPI Soft-Off機能が無効化されていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# loginctl show-user]{custom-style="Verbatim Char"}\
  [：(省略)]{custom-style="Verbatim Char"}\
  [HandlePowerKey=ignore]{custom-style="red-bold"}\
  [：(省略)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

