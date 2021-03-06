create or replace package ora_ver.P_OVC_LOCK is

  /*
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************

   Author  :  Kravchenko A.V.        
   Created : 15.04.10 15:45:11
   Purpose : ����������

  */

  

  -- ��������� ���������� �� �������
  function check_lock (p_obj_type in ovc_lock_object.obj_type%type,
                       p_obj_owner in ovc_lock_object.obj_owner%type,
                       p_obj_name in ovc_lock_object.obj_name%type) return ovc_lock_object%rowtype;                              

  -- ���������� ���������� �� ������
  procedure set_object_lock(p_obj_type in ovc_lock_object.obj_type%type,
                            p_obj_owner in ovc_lock_object.obj_owner%type,
                            p_obj_name in ovc_lock_object.obj_name%type,
                            p_is_full in ovc_lock_object.is_full%type,                            
                            p_lock_user in ovc_lock_object.lock_user%type default null,
                            p_lock_terminal in ovc_lock_object.lock_terminal%type default null,
                            p_lock_os_user in ovc_lock_object.lock_os_user%type default null,
                            p_note in ovc_lock_object.note%type default null,
                            p_check_exists in boolean default true);                              

  -- ����� ���������� �� ID
  procedure clear_lock(p_id ovc_lock_object.id%type);

  -- ����� ���������� �� ����� �������
  procedure clear_lock(p_obj_type in ovc_lock_object.obj_type%type,
                       p_obj_owner in ovc_lock_object.obj_owner%type,
                       p_obj_name in ovc_lock_object.obj_name%type);

end P_OVC_LOCK;
/

create or replace package body ora_ver.P_OVC_LOCK is

--��������� ���������� �� �������
function check_lock (p_obj_type in ovc_lock_object.obj_type%type,
                     p_obj_owner in ovc_lock_object.obj_owner%type,
                     p_obj_name in ovc_lock_object.obj_name%type) return ovc_lock_object%rowtype
is
  cursor c_check_lock(p_obj_type in ovc_lock_object.obj_type%type,
                      p_obj_owner in ovc_lock_object.obj_owner%type,
                      p_obj_name in ovc_lock_object.obj_name%type)
  is 
    select
      l.*
    from
      ovc_lock_object l
    where              
      l.obj_type = p_obj_type and
      l.obj_owner = p_obj_owner and
      l.obj_name = p_obj_name;     
  
  m_lock_object ovc_lock_object%rowtype;
begin
 
 open c_check_lock(p_obj_type, p_obj_owner, p_obj_name);
 fetch c_check_lock into m_lock_object;
 close c_check_lock;
 
 return m_lock_object;
 
end;
        

--���������� ���������� �� ������
procedure set_object_lock(p_obj_type in ovc_lock_object.obj_type%type,
                          p_obj_owner in ovc_lock_object.obj_owner%type,
                          p_obj_name in ovc_lock_object.obj_name%type,
                          p_is_full in ovc_lock_object.is_full%type,
                          p_lock_user in ovc_lock_object.lock_user%type default null,
                          p_lock_terminal in ovc_lock_object.lock_terminal%type default null,
                          p_lock_os_user in ovc_lock_object.lock_os_user%type default null,
                          p_note in ovc_lock_object.note%type default null,
                          p_check_exists in boolean default true)
is
  m_lock_object ovc_lock_object%rowtype;
begin
  m_lock_object := check_lock(p_obj_type, p_obj_owner, p_obj_name);
  
  if m_lock_object.id is not null and p_check_exists then 
    p_ovc_exception.raise_common_exception('������ %s ��� ������������.'||chr(10)
                                           ||'�����: %s; '||chr(10)
                                           ||'������������: %s;'||chr(10)
                                           ||'��������: %s;'||chr(10)
                                           ||'������������ ��: %s.'||chr(10)
                                           ||'%s',
                                           m_lock_object.obj_owner||'.'||m_lock_object.obj_name,
                                           to_char(m_lock_object.lock_time,'DD.MM.YYYY HH24:MI:SS'),
                                           m_lock_object.lock_user,
                                           m_lock_object.lock_terminal,
                                           m_lock_object.lock_os_user,
                                           m_lock_object.note);  

  end if;
  
  if m_lock_object.id is null then
    insert into ovc_lock_object(id,
                                obj_type,
                                obj_owner,
                                obj_name,
                                lock_user,
                                lock_terminal,
                                lock_os_user,
                                lock_time,
                                is_full,
                                note)
                          values
                                (ovc_lock_object_seq.nextval,
                                 p_obj_type, 
                                 p_obj_owner, 
                                 p_obj_name,
                                 nvl(p_lock_user,user),
                                 nvl(p_lock_terminal,p_ovc_utility.get_client_terminal_name),
                                 nvl(p_lock_os_user,p_ovc_utility.get_client_os_user),
                                 SYSTIMESTAMP,
                                 p_is_full,
                                 p_note);
  end if;                               
                               
end;                         

--����� ���������� �� ID
procedure clear_lock(p_id ovc_lock_object.id%type)
is
begin
  delete from ovc_lock_object l
  where 
    l.id = p_id;
end;

--����� ���������� �� ����� �������
procedure clear_lock(p_obj_type in ovc_lock_object.obj_type%type,
                     p_obj_owner in ovc_lock_object.obj_owner%type,
                     p_obj_name in ovc_lock_object.obj_name%type)
is                     
begin
  delete from ovc_lock_object l
  where
    l.obj_type = p_obj_type and
    l.obj_owner = p_obj_owner and
    l.obj_name = p_obj_name;
end;                     

end P_OVC_LOCK;
/

