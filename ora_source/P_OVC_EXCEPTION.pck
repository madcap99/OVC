create or replace package P_OVC_EXCEPTION is
  /*

   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************

   Author  :  Kravchenko A.V.
   Created : 15.04.10 15:48:11
   Purpose : ��������� ������

  */

  -- ��� ����������� ������
  g_common_error_code constant pls_integer :=-20000;
  g_system_error_code constant pls_integer :=-20100;

  -- ���������� ���������������� ������
  procedure raise_common_exception(p_message in varchar2,
                                   p_param_1 in varchar2 default null,
                                   p_param_2 in varchar2 default null,
                                   p_param_3 in varchar2 default null,
                                   p_param_4 in varchar2 default null,
                                   p_param_5 in varchar2 default null,
                                   p_param_6 in varchar2 default null,
                                   p_param_7 in varchar2 default null,
                                   p_param_8 in varchar2 default null,
                                   p_param_9 in varchar2 default null);

  -- ���������� ��������� ������
  procedure raise_system_exception(p_change_object_id in pls_integer,
                                   p_message in varchar2,
                                   p_param_1 in varchar2 default null,
                                   p_param_2 in varchar2 default null,
                                   p_param_3 in varchar2 default null,
                                   p_param_4 in varchar2 default null,
                                   p_param_5 in varchar2 default null,
                                   p_param_6 in varchar2 default null,
                                   p_param_7 in varchar2 default null,
                                   p_param_8 in varchar2 default null,
                                   p_param_9 in varchar2 default null);
  
  --������� ��� ������                                
  procedure clear_log;                                  

end P_OVC_EXCEPTION;
/
create or replace package body P_OVC_EXCEPTION is

procedure write_error_log(p_code             in pls_integer,
                          p_message          in varchar2,
                          p_change_object_id in pls_integer)
is
pragma autonomous_transaction;
begin
    insert into ovc_error_log(id,
                              error_time,
                              code,
                              message,
                              terminal,
                              os_user,
                              change_object_id)
                        values
                             (ovc_error_log_seq.nextval,
                              sysdate,
                              p_code,
                              substr(p_message,1,2000),
                              p_ovc_utility.get_client_terminal_name,
                              p_ovc_utility.get_client_os_user,
                              p_change_object_id);
  commit;
end;
--���������� ���������� ������
procedure raise_exception(p_code             in pls_integer,
                          p_write_log        in varchar2 default null,
                          p_silent           in varchar2 default null,
                          p_change_object_id in pls_integer default null,
                          p_message          in varchar2,
                          p_param_1          in varchar2 default null,
                          p_param_2          in varchar2 default null,
                          p_param_3          in varchar2 default null,
                          p_param_4          in varchar2 default null,
                          p_param_5          in varchar2 default null,
                          p_param_6          in varchar2 default null,
                          p_param_7          in varchar2 default null,
                          p_param_8          in varchar2 default null,
                          p_param_9          in varchar2 default null)
is

 m_write_log varchar2(1);
 m_silent varchar2(1);
 m_message varchar2(10000);
begin

  m_message := p_ovc_str_utils.format_string(p_message,
                                             p_param_1,
                                             p_param_2,
                                             p_param_3,
                                             p_param_4,
                                             p_param_5,
                                             p_param_6,
                                             p_param_7,
                                             p_param_8,
                                             p_param_9);

  if p_write_log is null then
    m_write_log := p_ovc_registry.get_value(p_path => 'ERROR',
                                           p_param => 'WRITE_LOG');
  else
    m_write_log := p_write_log;
  end if;

  if p_silent is null then
    m_silent := p_ovc_registry.get_value(p_path => 'ERROR',
                                        p_param => 'SILENT');
  else
    m_silent := p_silent;
  end if;

  if m_write_log = 'T' then
    write_error_log(p_code,m_message,p_change_object_id);
  end if;

  --�� ������ ������ ���� �������� � ���
  if m_silent = 'T' and m_write_log = 'T'  then
    null;
  else
    raise_application_error(p_code,
                            m_message);
  end if;

end;

-- ���������� ���������������� ������
procedure raise_common_exception(p_message in varchar2,
                                 p_param_1 in varchar2 default null,
                                 p_param_2 in varchar2 default null,
                                 p_param_3 in varchar2 default null,
                                 p_param_4 in varchar2 default null,
                                 p_param_5 in varchar2 default null,
                                 p_param_6 in varchar2 default null,
                                 p_param_7 in varchar2 default null,
                                 p_param_8 in varchar2 default null,
                                 p_param_9 in varchar2 default null)
is
begin

  raise_exception(p_code => g_common_error_code,
                  p_silent => 'F',
                  p_message => p_message,
                  p_param_1 => p_param_1,
                  p_param_2 => p_param_2,
                  p_param_3 => p_param_3,
                  p_param_4 => p_param_4,
                  p_param_5 => p_param_5,
                  p_param_6 => p_param_6,
                  p_param_7 => p_param_7,
                  p_param_8 => p_param_8,
                  p_param_9 => p_param_9);

end;

-- ���������� ��������� ������
procedure raise_system_exception(p_change_object_id pls_integer,
                                 p_message in varchar2,
                                 p_param_1 in varchar2 default null,
                                 p_param_2 in varchar2 default null,
                                 p_param_3 in varchar2 default null,
                                 p_param_4 in varchar2 default null,
                                 p_param_5 in varchar2 default null,
                                 p_param_6 in varchar2 default null,
                                 p_param_7 in varchar2 default null,
                                 p_param_8 in varchar2 default null,
                                 p_param_9 in varchar2 default null)
is
begin

  raise_exception(p_code => g_system_error_code,
                  p_write_log => null,
                  p_silent => null,
                  p_change_object_id => p_change_object_id,
                  p_message => p_message,
                  p_param_1 => p_param_1,
                  p_param_2 => p_param_2,
                  p_param_3 => p_param_3,
                  p_param_4 => p_param_4,
                  p_param_5 => p_param_5,
                  p_param_6 => p_param_6,
                  p_param_7 => p_param_7,
                  p_param_8 => p_param_8,
                  p_param_9 => p_param_9);

end;

--������� ��� ������                                
procedure clear_log
is
begin
  delete from ovc_error_log;
end;
  
end P_OVC_EXCEPTION;
/
