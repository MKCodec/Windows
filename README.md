# 🚀 Proxmox Windows Template (100% Automático)

Guia definitivo para criar um template Windows totalmente automatizado usando apenas comandos (CMD/PowerShell).

---

## 🎯 Objetivo

* Clonar VM sem interação
* Windows inicia direto no desktop
* Login automático
* Máquina única (SID, hostname, rede)
* Já com programas instalados
* Sem usar atalhos (Ctrl + Shift + F3)

---

## ⚙️ 1. Instalar o Windows (normal)

* Crie a VM no Proxmox
* Instale o Windows normalmente
* Finalize até entrar no desktop

👉 Aqui você pode logar normalmente (não tem problema)

---

## 🔧 2. Entrar em Audit Mode via comando

Abra **CMD como administrador** e execute:

```bat id="cmd1"
C:\Windows\System32\Sysprep\sysprep.exe /audit /reboot
```

👉 O Windows vai reiniciar em **Audit Mode automaticamente**

---

## 🧰 3. Preparar o sistema

Agora configure tudo que quer no template:

### 📦 Instalar programa (exemplo)

```bat id="cmd2"
C:\instaladores\app.exe /silent /norestart
```

---

### 📥 Baixar arquivo automaticamente

```powershell id="cmd3"
powershell -Command "Invoke-WebRequest -Uri 'https://site.com/arquivo.zip' -OutFile 'C:\Users\Public\Downloads\arquivo.zip'"
```

---

### 🧹 Limpeza (opcional)

```bat id="cmd4"
cleanmgr /sagerun:1
```

---

## 📄 4. Criar o unattend.xml (via PowerShell)

Crie o arquivo automaticamente:

```powershell id="cmd5"
@"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">

  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup">

      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
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

      <ComputerName>*</ComputerName>
      <TimeZone>E. South America Standard Time</TimeZone>

      <FirstLogonCommands>
        <SynchronousCommand>
          <Order>1</Order>
          <CommandLine>C:\setup\firstboot.bat</CommandLine>
        </SynchronousCommand>
      </FirstLogonCommands>

    </component>
  </settings>

</unattend>
"@ | Out-File -Encoding UTF8 C:\Windows\System32\Sysprep\unattend.xml
```

---

## 🔥 5. Criar script de primeiro boot

```bat id="cmd6"
mkdir C:\setup
```

```bat id="cmd7"
notepad C:\setup\firstboot.bat
```

Conteúdo:

```bat id="cmd8"
@echo off

:: hostname opcional custom
wmic computersystem where name="%computername%" call rename name="WIN-%RANDOM%"

:: exemplo: abrir programa
start "" "C:\Program Files\App\app.exe"

:: remover script
del "%~f0"
```

---

## ⚡ 6. Rodar Sysprep FINAL

Agora o mais importante:

```bat id="cmd9"
C:\Windows\System32\sysprep\sysprep.exe /oobe /generalize /shutdown /unattend:C:\Windows\System32\Sysprep\unattend.xml
```

---

## 🧠 O que acontece aqui

* `/generalize` → cria nova identidade
* `ComputerName=*` → hostname único automático
* Proxmox → MAC único
* XML → remove telas
* FirstBoot → executa script automático

---

## 📦 7. Converter em Template

No Proxmox:

* Clique na VM
* **Convert to Template**

---

## 🔁 8. Clonar via CLI

```bash id="cmd10"
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
* 📦 Programas já instalados
* 📥 Arquivos já baixados
* ⚙️ Zero configuração manual

---

## ⚠️ Checklist de segurança

✔ Usou `/generalize`
✔ XML correto
✔ Caminho do XML certo
✔ Não iniciou a VM antes de virar template

---

## 🧩 Conclusão

Esse método é:

* 🔥 Estável
* ⚡ Rápido
* 🧠 Escalável
* 💯 100% automatizado

Ideal pra rodar dezenas ou milhares de clones.
