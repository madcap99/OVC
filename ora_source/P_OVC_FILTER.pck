create or replace package P_OVC_FILTER is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
  Created : 20.04.10 12:11:55
  Purpose : �������

  */
  
  -- ������� ������
  procedure create_filter_template(p_id in out ovc_filter_template.id%type,
                                   p_name in ovc_filter_template.name%type,     
                                   p_obj_type in ovc_filter_template.obj_type%type default '%',
                                   p_obj_owner in ovc_filter_template.obj_owner%type default '%',
                                   p_obj_name in ovc_filter_template.obj_name%type default '%',
                                   p_modify_user in ovc_filter_template.modify_user%type default '%',
                                   p_modify_terminal in ovc_filter_template.modify_terminal%type default '%',
                                   p_modify_os_user in ovc_filter_template.modify_os_user%type default '%',
                                   p_ignore in ovc_filter_template.ignore%type default 'F');

  -- �������� ������
  procedure update_filter_template(p_id in ovc_filter_template.id%type,
                                   p_name in ovc_filter_template.name%type,
                                   p_obj_type in ovc_filter_template.obj_type%type,
                                   p_obj_owner in ovc_filter_template.obj_owner%type,
                                   p_obj_name in ovc_filter_template.obj_name%type,
                                   p_modify_user in ovc_filter_template.modify_user%type,
                                   p_modify_terminal in ovc_filter_template.modify_terminal%type,
                                   p_modify_os_user in ovc_filter_template.modify_os_user%type,
                                   p_ignore in ovc_filter_template.ignore%type);
                          
  -- ������� ������
  procedure delete_filter_template(p_id in ovc_filter_template.id%type);
  
  -- �������� ������ � ������
  procedure create_filter_set(p_id in out ovc_filter_set.id%type,
                              p_filter_id in ovc_filter_set.filter_id%type,
                              p_enabled in ovc_filter_set.enabled%type default 'T',
                              p_project_id in ovc_filter_set.project_id%type default null,
                              p_is_auto_lock in ovc_filter_set.is_auto_lock%type default 'F',
                              p_revision_template_id in ovc_filter_set.revision_template_id%type default null);

  -- �������� ������ � ������
  procedure update_filter_set(p_id in ovc_filter_set.id%type,
                              p_filter_id in ovc_filter_set.filter_id%type,
                              p_enabled in ovc_filter_set.enabled%type,
                              p_project_id in ovc_filter_set.project_id%type,
                              p_is_auto_lock in ovc_filter_set.is_auto_lock%type,
                              p_revision_template_id in ovc_filter_set.revision_template_id%type default null);

  -- ������� ������ �� ������
  procedure delete_filter_set(p_id in ovc_filter_set.id%type);
  
  -- �������� ������ � ������
  procedure enable_filter_set(p_id in ovc_filter_set.id%type);                               
  
  -- ��������� ������ � ������
  procedure disable_filter_set(p_id in ovc_filter_set.id%type);                               
  
                                 
end P_OVC_FILTER;
/
create or replace package body P_OVC_FILTER is

-- �������� ��� ��������� �������
function get_change_filter_type(p_id in ovc_filter_set.id%type) return ovc_filter_set.type%type
is
  cursor c_get_type(p_id ovc_filter_set.id%type)
  is
    select
      f.type
    from
      ovc_filter_set f
    where
      f.id = p_id;    
  m_type ovc_filter_set.type%type;      
begin
  open c_get_type(p_id);
  fetch c_get_type into m_type;
  close c_get_type;
  
  if m_type is null then 
    p_ovc_exception.raise_common_exception('�� ������ ������ � ������ ID=%s',p_id);
  end if;
  
  return m_type;
end;

-- ������� ������
procedure create_filter_template(p_id in out ovc_filter_template.id%type,
                        p_name in ovc_filter_template.name%type,
                        p_obj_type in ovc_filter_template.obj_type%type default '%',
                        p_obj_owner in ovc_filter_template.obj_owner%type default '%',
                        p_obj_name in ovc_filter_template.obj_name%type default '%',
                        p_modify_user in ovc_filter_template.modify_user%type default '%',
                        p_modify_terminal in ovc_filter_template.modify_terminal%type default '%',
                        p_modify_os_user in ovc_filter_template.modify_os_user%type default '%',
                        p_ignore in ovc_filter_template.ignore%type default 'F')
is 
begin
  if p_id is null then 
    select ovc_filter_seq.nextval into p_id from dual;
  end if;
  
  insert into ovc_filter_template (id,
                                   name,
                                   obj_type,
                                   obj_owner,
                                   obj_name,
                                   modify_user,
                                   modify_terminal,
                                   modify_os_user,
                                   ignore)  
                             values     
                                  (p_id,
                                  p_name,
                                  p_obj_type,
                                  p_obj_owner,
                                  p_obj_name,
                                  p_modify_user,
                                  p_modify_terminal,
                                  p_modify_os_user,
                                  p_ignore);
                          
end;                        

-- �������� ������
procedure update_filter_template(p_id in ovc_filter_template.id%type,
                                 p_name in ovc_filter_template.name%type,
                                 p_obj_type in ovc_filter_template.obj_type%type,
                                 p_obj_owner in ovc_filter_template.obj_owner%type,
                                 p_obj_name in ovc_filter_template.obj_name%type,
                                 p_modify_user in ovc_filter_template.modify_user%type,
                                 p_modify_terminal in ovc_filter_template.modify_terminal%type,
                                 p_modify_os_user in ovc_filter_template.modify_os_user%type,
                                 p_ignore in ovc_filter_template.ignore%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID �������');
  end if;
  
  update ovc_filter_template f set
    f.name = p_name,
    f.obj_type = p_obj_type,
    f.obj_owner = p_obj_owner,
    f.obj_name = p_obj_name,
    f.modify_user = p_modify_user,
    f.modify_terminal = p_modify_terminal,
    f.modify_os_user = p_modify_os_user,
    f.ignore = p_ignore
  where
    f.id = p_id;   
    
end;                        
                          
-- ������� ������
procedure delete_filter_template(p_id in ovc_filter_template.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID �������');
  end if;
  
  delete from ovc_filter_template f where f.id = p_id;
  
end;

-- �������� ������ � ������
procedure create_filter_set(p_id in out ovc_filter_set.id%type,
                            p_filter_id in ovc_filter_set.filter_id%type,
                            p_enabled in ovc_filter_set.enabled%type default 'T',
                            p_project_id in ovc_filter_set.project_id%type default null,
                            p_is_auto_lock in ovc_filter_set.is_auto_lock%type default 'F',
                            p_revision_template_id in ovc_filter_set.revision_template_id%type default null)
is
begin
  if p_id is null then 
    select ovc_filter_set_seq.nextval into p_id from dual;
  end if;
  
  insert into ovc_filter_set(id,
                             filter_id,
                             enabled,
                             type,
                             project_id,
                             is_auto_lock,
                             revision_template_id)
                       values
                            (p_id,
                             p_filter_id,
                             p_enabled,
                             decode(p_project_id,null,decode(p_revision_template_id,null,'SYSTEM','REVISION'),'PROJECT'),
                             p_project_id,
                             p_is_auto_lock,
                             p_revision_template_id);
                                      
end;                               

-- �������� ������ � ������
procedure update_filter_set(p_id in ovc_filter_set.id%type,
                            p_filter_id in ovc_filter_set.filter_id%type,
                            p_enabled in ovc_filter_set.enabled%type,
                            p_project_id in ovc_filter_set.project_id%type,
                            p_is_auto_lock in ovc_filter_set.is_auto_lock%type,
                            p_revision_template_id in ovc_filter_set.revision_template_id%type default null)
is

begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID ������� � ������');
  end if;
  
  if get_change_filter_type(p_id) = 'PROJECT' and p_project_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID �������.');

  elsif get_change_filter_type(p_id) = 'REVISION' and p_revision_template_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID ������� �������.');
    
  elsif get_change_filter_type(p_id) = 'SYSTEM' and (p_project_id is not null or p_revision_template_id is not null) then
    p_ovc_exception.raise_common_exception('��� ������� �� ����� ���� �������.');
  end if;
  
  update ovc_filter_set f set
    f.filter_id = p_filter_id,
    f.enabled = p_enabled,
    f.project_id = p_project_id,
    f.is_auto_lock = p_is_auto_lock,
    f.revision_template_id = p_revision_template_id
  where
    f.id = p_id;   
end;                               
                               

-- ������� ������ �� ������
procedure delete_filter_set(p_id in ovc_filter_set.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID ������� � ������');
  end if;
  
  delete from ovc_filter_set f where f.id = p_id;  
end;                               
  
-- �������� ������ � ������
procedure enable_filter_set(p_id in ovc_filter_set.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID ������� � ������');
  end if;
  
  update ovc_filter_set f set
    f.enabled = 'T'
  where
    f.id = p_id;  
end;                               
  
-- ��������� ������ � ������
procedure disable_filter_set(p_id in ovc_filter_set.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('�� ����� ID ������� � ������');
  end if;
  
  update ovc_filter_set f set
    f.enabled = 'F'
  where
    f.id = p_id;
end;                               

end P_OVC_FILTER;
/
