#!/bin/sh

#
# OpenWRT
#

if [ -f /etc/openwrt_release ]; then
  echo "Определена платформа OpenWRT"

  if [ -f /bin/opkg ]; then
    echo "Определен пакетный менеджер opkg"

    found=0
    opkg_repos=""

    while read -r _ ARCH _; do
      if [ "$ARCH" = "aarch64_cortex-a53" ] \
      || [ "$ARCH" = "aarch64_cortex-a72" ] \
      || [ "$ARCH" = "aarch64_cortex-a76" ] \
      || [ "$ARCH" = "aarch64_generic" ] \
      || [ "$ARCH" = "arm_arm1176jzf-s_vfp" ] \
      || [ "$ARCH" = "arm_arm926ej-s" ] \
      || [ "$ARCH" = "arm_cortex-a15_neon-vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a5_vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a7" ] \
      || [ "$ARCH" = "arm_cortex-a7_neon-vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a7_vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a8_vfpv3" ] \
      || [ "$ARCH" = "arm_cortex-a9" ] \
      || [ "$ARCH" = "arm_cortex-a9_neon" ] \
      || [ "$ARCH" = "arm_cortex-a9_vfpv3-d16" ] \
      || [ "$ARCH" = "arm_fa526" ] \
      || [ "$ARCH" = "arm_xscale" ] \
      || [ "$ARCH" = "i386_pentium4" ] \
      || [ "$ARCH" = "i386_pentium-mmx" ] \
      || [ "$ARCH" = "loongarch64_generic" ] \
      || [ "$ARCH" = "mips_24kc" ] \
      || [ "$ARCH" = "mips_4kec" ] \
      || [ "$ARCH" = "mips64el_mips64r2" ] \
      || [ "$ARCH" = "mips64_mips64r2" ] \
      || [ "$ARCH" = "mips64_octeonplus" ] \
      || [ "$ARCH" = "mipsel_24kc_24kf" ] \
      || [ "$ARCH" = "mipsel_24kc" ] \
      || [ "$ARCH" = "mipsel_74kc" ] \
      || [ "$ARCH" = "mipsel_mips32" ] \
      || [ "$ARCH" = "mips_mips32" ] \
      || [ "$ARCH" = "riscv64_generic" ] \
      || [ "$ARCH" = "x86_64" ]; then
        echo "Определена архитектура: $ARCH"
        found=1
        opkg_repos="${opkg_repos}src/gz magitrickle_${ARCH} https://bin.magitrickle.dev/packages/openwrt/snapshots-ipk/${ARCH}
"
      fi
    done <<EOF
$(/bin/opkg print-architecture)
EOF

    if [ "$found" -eq 0 ]; then
      echo "Не найдено поддерживаемых архитектур" >&2
      exit 1
    fi

    mkdir -p /etc/opkg
    printf "%s\n" "$opkg_repos" > /etc/opkg/magitrickle.conf

    mkdir -p /etc/opkg/keys
    wget -O /etc/opkg/keys/6cef96cd3b8f66b0 "https://bin.magitrickle.dev/packages/openwrt/snapshots-ipk/6cef96cd3b8f66b0.pub"

    echo "Репозиторий успешно добавлен!"
    echo "Не забудь выполнить \"opkg update && opkg install magitrickle\"!"

    exit 0
  elif [ -f /usr/bin/apk ]; then
    echo "Определен пакетный менеджер apk"

    APK_REPOS_FILE="/etc/apk/repositories.d/distfeeds.list"
    if [ ! -f "${APK_REPOS_FILE}" ]; then
      echo "Не удалось определить архитектуру" >&2
      exit 1
    fi

    found=0
    apk_repos=""

    while IFS= read -r url; do
      case "${url}" in
        ""|\#*) continue ;;
      esac
      ARCH=$(echo "${url}" | sed -n 's|.*/\([^/]*\)/packages/packages\.adb$|\1|p')
      if [ "$ARCH" = "aarch64_cortex-a53" ] \
      || [ "$ARCH" = "aarch64_cortex-a72" ] \
      || [ "$ARCH" = "aarch64_cortex-a76" ] \
      || [ "$ARCH" = "aarch64_generic" ] \
      || [ "$ARCH" = "arm_arm1176jzf-s_vfp" ] \
      || [ "$ARCH" = "arm_arm926ej-s" ] \
      || [ "$ARCH" = "arm_cortex-a15_neon-vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a5_vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a7" ] \
      || [ "$ARCH" = "arm_cortex-a7_neon-vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a7_vfpv4" ] \
      || [ "$ARCH" = "arm_cortex-a8_vfpv3" ] \
      || [ "$ARCH" = "arm_cortex-a9" ] \
      || [ "$ARCH" = "arm_cortex-a9_neon" ] \
      || [ "$ARCH" = "arm_cortex-a9_vfpv3-d16" ] \
      || [ "$ARCH" = "arm_fa526" ] \
      || [ "$ARCH" = "arm_xscale" ] \
      || [ "$ARCH" = "i386_pentium4" ] \
      || [ "$ARCH" = "i386_pentium-mmx" ] \
      || [ "$ARCH" = "loongarch64_generic" ] \
      || [ "$ARCH" = "mips_24kc" ] \
      || [ "$ARCH" = "mips_4kec" ] \
      || [ "$ARCH" = "mips64el_mips64r2" ] \
      || [ "$ARCH" = "mips64_mips64r2" ] \
      || [ "$ARCH" = "mips64_octeonplus" ] \
      || [ "$ARCH" = "mipsel_24kc_24kf" ] \
      || [ "$ARCH" = "mipsel_24kc" ] \
      || [ "$ARCH" = "mipsel_74kc" ] \
      || [ "$ARCH" = "mipsel_mips32" ] \
      || [ "$ARCH" = "mips_mips32" ] \
      || [ "$ARCH" = "riscv64_generic" ] \
      || [ "$ARCH" = "x86_64" ]; then
        echo "Определена архитектура: $ARCH"
        found=1
        apk_repos="${apk_repos}https://bin.magitrickle.dev/packages/openwrt/snapshots-apk/${ARCH}/packages.adb
"
      fi
    done < "${APK_REPOS_FILE}"

    if [ "${found}" -eq 0 ]; then
      echo "Не найдено поддерживаемых архитектур" >&2
      exit 1
    fi

    mkdir -p /etc/apk/repositories.d
    printf "%s\n" "$apk_repos" > /etc/apk/repositories.d/magitrickle.list

    mkdir -p /etc/apk/keys
    wget -O /etc/apk/keys/magitrickle.pem "https://bin.magitrickle.dev/packages/openwrt/snapshots-apk/magitrickle.pub.pem"

    echo "Репозиторий успешно добавлен!"
    echo "Не забудь выполнить \"apk update && apk add magitrickle\"!"

    exit 0
  else
    echo "Не обнаружен ни один поддерживаемый пакетный менеджер" >&2
    exit 1
  fi
fi

#
# Entware
#

if [ -f /opt/etc/entware_release ]; then
  echo "Определена платформа Entware"

  found=0
  opkg_repos=""

  while read -r _ ARCH _; do
    if [ "$ARCH" = "aarch64-3.10" ] \
    || [ "$ARCH" = "aarch64-3.10_kn" ] \
    || [ "$ARCH" = "armv7-3.2" ] \
    || [ "$ARCH" = "mips-3.4" ] \
    || [ "$ARCH" = "mips-3.4_kn" ] \
    || [ "$ARCH" = "mipsel-3.4" ] \
    || [ "$ARCH" = "mipsel-3.4_kn" ]; then
      echo "Определена архитектура: $ARCH"
      found=1
      opkg_repos="${opkg_repos}src/gz magitrickle_${ARCH} http://bin.magitrickle.dev/packages/entware/${ARCH}
"
    fi
  done <<EOF
$(/opt/bin/opkg print-architecture)
EOF

  if [ "$found" -eq 0 ]; then
    echo "Не найдено поддерживаемых архитектур" >&2
    exit 1
  fi

  mkdir -p /opt/etc/opkg
  printf "%s\n" "$opkg_repos" > /opt/etc/opkg/magitrickle.conf

  echo "Репозиторий успешно добавлен!"
  echo "Не забудь выполнить \"opkg update && opkg install magitrickle\"!"

  exit 0
fi

#
# Unknown
#

echo "Не удалось определить платформу" >&2
exit 1
