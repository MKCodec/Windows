# 🚀 Proxmox Windows Template (100% Automático)

Guia definitivo para criar um template Windows totalmente automatizado usando apenas comandos (CMD/PowerShell).

---

## 🎯 Objetivo

* Clonar VM sem interação
* Windows inicia direto no desktop
* Login automático
* Máquina única (SID, hostname, rede)
* Programas instalados automaticamente no primeiro boot
* Sem usar atalhos (Ctrl + Shift + F3)

---

## ⚙️ 1. Instalar o Windows (normal)

* Crie a VM no Proxmox
* Instale o Windows normalmente
* Finalize até entrar no desktop

👉 Pode logar normalmente (sem problema)

---

## 🔧 2. Entrar em Audit Mode via comando

Abra **CMD como administrador** e execute:

```bat
C:\Windows\System32\Sysprep\sysprep.exe /audit /reboot
```

👉 O Windows reiniciará em **Audit Mode automaticamente**

---

## 🧰 3. Preparar o sistema

Configure tudo que deseja no template:

### 📦 Instalar programas

```bat
C:\instaladores\app.exe /silent /norestart
```

---

### 📥 Baixar arquivos automaticamente

```powershell
powershell -Command "Invoke-WebRequest -Uri 'https://site.com/arquivo.zip' -OutFile 'C:\Users\Public\Downloads\arquivo.zip'"
```

---

### 🧹 Limpeza (opcional)

```bat
cleanmgr /sagerun:1
```

---

## 📄 4. Criar o unattend.xml

```powershell
@"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">

  <settings pass="specialize">
    <component name="Microsoft-Windows-International-Core"
               processorArchitecture="amd64"
               publicKeyToken="31bf3856ad364e35"
               language="neutral"
               versionScope="nonSxS">
      <InputLocale>0409:00000409</InputLocale>
      <SystemLocale>en-US</SystemLocale>
      <UILanguage>en-US</UILanguage>
      <UserLocale>en-US</UserLocale>
    </component>

    <component name="Microsoft-Windows-Shell-Setup"
               processorArchitecture="amd64"
               publicKeyToken="31bf3856ad364e35"
               language="neutral"
               versionScope="nonSxS">
      <ComputerName>*</ComputerName>
    </component>
  </settings>

  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-International-Core"
               processorArchitecture="amd64"
               publicKeyToken="31bf3856ad364e35"
               language="neutral"
               versionScope="nonSxS">
      <InputLocale>0409:00000409</InputLocale>
      <SystemLocale>en-US</SystemLocale>
      <UILanguage>en-US</UILanguage>
      <UserLocale>en-US</UserLocale>
    </component>

    <component name="Microsoft-Windows-Shell-Setup"
               processorArchitecture="amd64"
               publicKeyToken="31bf3856ad364e35"
               language="neutral"
               versionScope="nonSxS">
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideLocalAccountScreen>true</HideLocalAccountScreen>
        <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
        <NetworkLocation>Work</NetworkLocation>
        <ProtectYourPC>1</ProtectYourPC>
      </OOBE>

      <AutoLogon>
        <Username>Administrator</Username>
        <Enabled>true</Enabled>
        <LogonCount>999</LogonCount>
      </AutoLogon>

      <UserAccounts>
        <AdministratorPassword>
          <Value></Value>
          <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>

      <TimeZone>E. South America Standard Time</TimeZone>
    </component>
  </settings>

</unattend>
"@ | Out-File C:\Windows\System32\Sysprep\unattend.xml -Encoding utf8
```

---

## 🔥 5. Criar SetupComplete (EXECUTA COMO ADMIN)

```bat
mkdir C:\Windows\Setup\Scripts
```

```bat
notepad C:\Windows\Setup\Scripts\SetupComplete.cmd
```

Conteúdo:

```bat
@echo off

timeout /t 20

:retry
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdn.earnapp.com/static/earnapp-setup-latest.exe' -OutFile 'C:\earnapp.exe' -ErrorAction Stop } catch { exit 1 }"
if not exist C:\earnapp.exe goto retry

start /wait "" C:\earnapp.exe /S

del C:\earnapp.exe
```

---

## ⚡ 6. Rodar Sysprep FINAL

```bat
C:\Windows\System32\sysprep\sysprep.exe /oobe /generalize /shutdown /unattend:C:\Windows\System32\Sysprep\unattend.xml
```

---

## 🧠 O que acontece

* `/generalize` → nova identidade (SID único)
* `ComputerName=*` → hostname automático
* Proxmox → MAC único
* XML → remove telas de configuração
* `SetupComplete.cmd` → executa como SYSTEM (admin total)

---

## 📦 7. Converter em Template

No Proxmox:

* Selecione a VM
* Clique em **Convert to Template**

---

## 🔁 8. Clonar via CLI

```bash
qm clone 100 200 --name win-200 --full false
qm start 200
```

---

## ✅ Resultado Final

Cada VM clonada:

* 🚀 Abre direto no desktop
* 🔐 Login automático
* 🆔 SID único
* 🖥️ Hostname único
* 🌐 MAC único
* 📦 Programas instalados automaticamente
* ⚙️ Zero configuração manual

---

## ⚠️ Checklist

* ✔ Usou `/generalize`
* ✔ XML no caminho correto
* ✔ Não iniciou a VM antes de virar template
* ✔ SetupComplete criado corretamente

---

## 🧩 Conclusão

Esse método é:

* 🔥 Estável
* ⚡ Rápido
* 🧠 Escalável
* 💯 Totalmente automatizado

Perfeito para rodar dezenas ou milhares de clones no Proxmox.
