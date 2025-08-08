; -----------------------------------------------------------------------------
; mod_openini.as - ini�t�@�C�����샂�W���[��
; Version 1.0 [2024.02.29]
; Copyright (c) 2024 Lala Madotuki
; -----------------------------------------------------------------------------
; ini�t�@�C���̓ǂݏ������s�����W���[���ł��B
; -----------------------------------------------------------------------------
; �R�s�y�p
; #include "mod_openini.as"
; -----------------------------------------------------------------------------

#ifndef __MOD_OPENINI__
#define __MOD_OPENINI__

#include "kernel32.as"
#module "mod_openini"

// ini�t�@�C�����w��
#deffunc setini_file str _file, int _p
    sdim file,strlen(_file)+1: file=_file
    size=_p: if size=0 { size=300 }    // �ȗ����� 300bytes
    return

// �ݒ�t�@�C������ǂݏo��(���l)
#defcfunc getini_int str _sec, str _key, int _def
    return int(getini_str(_sec,_key,str(_def)))

// �ݒ�t�@�C������ǂݏo��(������)
#defcfunc getini_str str _sec, str _key, str _def, local _buf
    sdim _buf,size
    GetPrivateProfileString _sec,_key,_def,varptr(_buf),size,file
    return _buf

// �ݒ�t�@�C���ɏ�������(���l)
#deffunc setini_int str _sec, str _key, int _p
    setini_str _sec,_key,str(_p)
    return

// �ݒ�t�@�C���ɏ�������(������)
#deffunc setini_str str _sec, str _key, str _p
    WritePrivateProfileString _sec,_key,_p,file
    return

#global
#endif