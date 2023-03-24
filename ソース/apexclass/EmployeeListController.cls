public class EmployeeListController {

    /* 社員名簿管理画面　コントローラー */
    /* Author 小倉肇 */
    /* 検索メソッド */
    
    //変数宣言
    public List<Employee__c> searchResult{get;set;}
    public Employee__c searchParams{get;set;}
    public Employee__c editResult{get;set;}
    public Employee__c newEmployeeData{get;set;}
    public Id selectedId{get;set;}
    
    //コンストラクタ
    public EmployeeListController()
    {        
        searchResult = new List<Employee__c>();
        searchParams = new Employee__c();
        editResult = new Employee__c();
        newEmployeeData = new Employee__c();
    }
    
    public pageReference searchEmployees() 
    {
        String sql = getEmployeeData(searchParams);

        searchResult = Database.query(sql);
        
        if(searchResult.size() == 0)
        {
            Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, messageUtils('e01')));
        }
        
        return null;
    }
    
    public pageReference openEmployeeEditPage()
    {
        getEditEmployees(selectedId);
        
        PageReference childPage = Page.EmployeeEditPage;
        
        return childPage; 
    }
    
    public pageReference updateAndCloseEditPage()
    {
        update editResult;
        
        searchEmployees();
        
        PageReference parentPage = Page.EmployeeListPage;
        
        return parentPage;
    }
    
    public pageReference deleteAndCloseEditPage()
    {
        if (editResult.Employee_Status__c == true)
        {
            Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, messageUtils('e02')));
            return null;
        }
        delete editResult;
        
        searchEmployees();
        
        PageReference parentPage = Page.EmployeeListPage;
        
        return parentPage;        
    }
    
    public pageReference createEmployee()
    {
        insert newEmployeeData;
        return null;
    }
    
    public string getEmployeeData(Employee__c params)
    {
        String sql;
        
        sql = 'SELECT' +
                  ' Id' +
                  ',Name' +
                  ',Employee_Name__c' +
                  ',Join_Date__c' +
                  ',Resignation_Date__c' +
                  ',Birth_Place__c' +
                  ',Years_of_Service__c' +
                  ',Position__c' +
                  ',Manager__r.Employee_Name__c' +
                  ',Skills__c' +
                  ',Employee_Description__c' +
                  ',Employee_Status__c' +
              ' FROM ' +
                  'Employee__c' +
              ' WHERE '
             ;
        
        if (params.Employee_Status__c == false)
        {
            sql = sql + 'Employee_Status__c = false ';
        }
        else
        {
            sql = sql + 'Employee_Status__c = true ';
        }
        
        if (params.Name != '')
        {
            sql = sql + 'AND Name = ' + '\'' + params.Name + '\''; //完全一致
        }
        
        if (params.Employee_Name__c != '')
        {
            sql = sql + ' AND Employee_Name__c LIKE' + '\'%' + params.Employee_Name__c + '%\''; //部分一致
        }   
        
        if (params.Join_Date__c != null)
        {
            sql = sql + 'AND Join_Date__c >= ' + params.Join_Date__c;
        }
        
        if (params.Position__c != null)
        {
            sql = sql + 'AND Position__c = ' + '\'' + params.Position__c + '\''; 
        }
        
        sql = sql + ' ORDER BY Name ';    
        
        return sql;
    }  
    
    public pageReference getEditEmployees(Id selectedId)
    {
        editResult = 
            [SELECT 
                 Name, 
                 Employee_Name__c, 
                 Join_Date__c, 
                 Resignation_Date__c, 
                 Birth_Place__c, 
                 Years_of_Service__c, 
                 Position__c, 
                 Manager__r.Employee_Name__c, 
                 Skills__c, 
                 Employee_Description__c, 
                 Employee_Status__c 
             FROM 
                 Employee__c 
             WHERE 
                 Id = :selectedId];
        
        return null;
    }
    
    public string messageUtils(string params)
    {
        Map<string, String> messageList = new Map<string, string>
        {
            'e01' => '検索結果は0件です'
           ,'e02' => '在籍中の社員は削除できません'
        };
        
        String message = messageList.get(params);
        
        return message;
    }
}