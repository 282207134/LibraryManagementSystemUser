// Each entry follows AppLanguage's order: Chinese, English, Japanese.
const borrowingStrings = <String, List<String>>{
  'loan_requests': ['借阅申请', 'Requests', '貸出申請'],
  'loan_view_borrows': [
    '查看我的借阅与凭证',
    'View my borrowings and pass',
    '貸出状況・受付コードを見る'
  ],
  'loan_request': ['申请借阅', 'Request book', '貸出を申請'],
  'loan_pending': ['待管理员确认', 'Awaiting staff', '職員の確認待ち'],
  'loan_approved': ['已确认借出', 'Checked out', '貸出済み'],
  'loan_rejected': ['已拒绝', 'Rejected', '却下'],
  'loan_cancelled': ['已取消', 'Cancelled', 'キャンセル済み'],
  'loan_expired': ['已过期', 'Expired', '期限切れ'],
  'loan_returned': ['已归还', 'Returned', '返却済み'],
  'loan_borrowed': ['借阅中', 'On loan', '貸出中'],
  'loan_overdue': ['已逾期', 'Overdue', '延滞中'],
  'loan_lost': ['遗失', 'Lost', '紛失'],
  'loan_pass': ['借阅凭证', 'Library pass', '貸出受付コード'],
  'loan_show_pass': ['出示凭证', 'Show pass', 'コードを表示'],
  'loan_pass_hint': [
    '到馆出示此码，由管理员核对后确认借出；归还时也可使用。',
    'Show this pass at the library. Staff confirm checkout and return.',
    '来館時に提示してください。職員が確認して貸出・返却を行います。'
  ],
  'loan_policy': [
    '申请保留 48 小时，不预留库存；管理员确认后开始计算借期。',
    'Requests last 48 hours and do not reserve stock. The loan starts after staff approval.',
    '申請は48時間有効です。在庫は確保されず、職員の確認後に貸出期間が始まります。'
  ],
  'loan_requested': [
    '申请已提交，请出示凭证由管理员确认。',
    'Request submitted. Show your pass to staff.',
    '申請しました。受付コードを職員に提示してください。'
  ],
  'loan_cancel_request': ['取消申请', 'Cancel request', '申請をキャンセル'],
  'loan_cancel_confirm': [
    '确定取消这条借阅申请吗？',
    'Cancel this borrowing request?',
    'この貸出申請をキャンセルしますか？'
  ],
  'loan_request_date': ['申请时间', 'Requested', '申請日時'],
  'loan_expiry': ['有效期至', 'Valid until', '有効期限'],
  'loan_note': ['审核说明', 'Staff note', '審査メモ'],
  'loan_return_hint': [
    '请携带图书到馆，由管理员确认归还。',
    'Bring the book to the library. Staff confirm its return.',
    '図書を図書館に持参してください。職員が返却を確認します。'
  ],
  'loan_empty_requests': ['暂无借阅申请', 'No requests yet', '貸出申請はありません'],
  'loan_empty_current': ['暂无借阅中的图书', 'No current loans', '貸出中の図書はありません'],
  'loan_empty_history': ['暂无借阅历史', 'No borrowing history', '貸出履歴はありません'],
  'loan_load_failed': [
    '借阅记录加载失败，请重试。',
    'Could not load borrowings. Please retry.',
    '貸出記録を読み込めませんでした。再試行してください。'
  ],
  'loan_refresh': ['刷新', 'Refresh', '更新'],
  'loan_retry': ['重试', 'Retry', '再試行'],
  'loan_copy': ['复制数字码', 'Copy code', 'コードをコピー'],
  'loan_copied': ['已复制', 'Copied', 'コピー済み'],
  'loan_invalid_pass': [
    '凭证格式无效，请刷新记录。',
    'Invalid pass. Refresh your records.',
    'コードが無効です。記録を更新してください。'
  ],
  'loan_unknown_book': ['未知图书', 'Unknown book', '不明な図書'],
  'loan_due': ['到期日期', 'Due date', '返却期限'],
  'loan_borrowed_date': ['借出日期', 'Checked out', '貸出日'],
  'loan_returned_date': ['归还日期', 'Returned', '返却日'],
  'loan_days_left': ['剩余天数', 'Days remaining', '残り日数'],
  'loan_days_overdue': ['逾期天数', 'Days overdue', '延滞日数'],
  'loan_action_failed': [
    '操作未完成，请刷新记录后重试。',
    'Not completed. Refresh your records and retry.',
    '処理できませんでした。記録を更新して再試行してください。'
  ],
};
