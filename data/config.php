<?php

/**
 * 最多保存多少條測試記錄
 */
const MAX_LOG_COUNT = 500;

/**
 * IP運營商解析服務：(1) ip.sb | (2) ipinfo.io （如果1解析ip異常，請切換成2）
 */
const IP_SERVICE = 'ip.sb';

/**
 * 是否允許同一IP記錄多條測速結果
 */
const SAME_IP_MULTI_LOGS = true;


/**
 * 是否使用完整 IP
 */
const Complete_IP_LOGS = true;