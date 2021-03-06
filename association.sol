pragma solidity ^0.4.19;

//Association Where Which Associate Can Make and Vote For Laws/Expenses If Pays his Fees
//Law Approved and/or Money Transfered From Association If Acceptance >= minPermingForQuorum
//Ideal For Condominium. Set To Have totalPerming Of 1000;
contract association {
    
    //Struct Law To Form An Array Of Proposed Laws
    struct law {
        uint acceptance;
        uint discord;
        string details;
    }
    law[] laws;
    
    //Struct Expense To Form An Array Of Proposed Expenses
    struct expense {
        uint acceptance;
        uint discord;
        address recipient;
        uint amount;
        bool paid;
    }
    expense[] expenses;
    
    //Contract Variables
    uint creationDate;
    uint minPermingForQuorum;
    uint monthlyFee;
    address associationAccount;                     //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO

    //Contract Mappings
    mapping(address => uint) perming;
    mapping(address => uint) amountPaid;
    mapping(address => uint) lastLawVoted;
    mapping(address => uint) lastExpenseVoted;

    //Contract Events 
 	event lawCreated(uint id, string details); 
    event lawVoted(uint id, address voter, bool decision);

    event expenseCreated(uint _id, address _recipient, uint _amount);
    event expenseVoted(uint id, address voter, bool decision);
    event expensePaid(uint _id, address _recipient, uint _amount);

 	event feePaid(address oldOwner, uint amount); 
 	event fractionSold(address oldOwner, uint perming, address newOwner); 

    //Create Association Contract
    function association(address[] _owners, uint[] _perming, uint _monthlyFee, uint _minPermingForQuorum) public {
        //Give Ownership of each fraction
        uint _i;
        while (_perming[_i] > 0) {
            perming[_owners[_i]] = _perming[_i];
            _i++;
        }

        //Initialize Contract Variables
        creationDate=now;
        monthlyFee=_monthlyFee;
        minPermingForQuorum=_minPermingForQuorum;
        //TODO Set/Return associationAccount        //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO
    }
    
    //Sell Your Association Fraction, Or A Portion Of
    function sellFraction(address _newOwner, uint _permingGiven) public {
        //Constraints
        require(perming[msg.sender] >= _permingGiven);
        //TODO Require Fees Paid
        
        //Make Transaction: 1st Transfer Perming
        perming[_newOwner] = perming[_newOwner] + _permingGiven;
        perming[msg.sender] = perming[msg.sender] - _permingGiven;

        //Make Transaction: 2nd Transfer Last Law/Expense Vote (Keep Higher Value, If Already Member We Don't Want a Double Vote Entry)
        if (lastLawVoted[_newOwner] < lastLawVoted[msg.sender]) {
            lastLawVoted[_newOwner] = lastLawVoted[msg.sender];
        }
        if (lastExpenseVoted[_newOwner] < lastExpenseVoted[msg.sender]) {
            lastExpenseVoted[_newOwner] = lastExpenseVoted[msg.sender];
        }

        //Make Transaction: 3rd Transfer Amount Paid
        amountPaid[_newOwner] = amountPaid[_newOwner] + amountPaid[msg.sender] * _permingGiven / perming[msg.sender];
        amountPaid[msg.sender] = amountPaid[msg.sender] - amountPaid[msg.sender] * _permingGiven / perming[msg.sender];

        //Event
        fractionSold(msg.sender, _permingGiven, _newOwner);
    }
    
    //Pay Monthly Fees
    function payFees() public payable {
        //Event
        feePaid(msg.sender, msg.value);
        
        //Transfer Funds
        amountPaid[msg.sender] = amountPaid[msg.sender] + msg.value;
    }
    
    //Create Law
    function createLaw(string _details) public {
        //Constraints
        require(perming[msg.sender] > 0);
        //Require Fees Paid                         //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO

        //Create Law
        uint _id = laws.push(law(perming[msg.sender], 0, _details)) - 1;
        
        //Event
        lawCreated(_id, _details);
    }

    //Create Expense
    function createExpense(address _recipient, uint _amount) public {
        //Constraints
        require(perming[msg.sender] > 0);
        //Require Fees Paid                         //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO
        //Require Enough Money On Contract To Pay   //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO
        
        //Create Expense
        uint _id = expenses.push(expense(perming[msg.sender], 0, _recipient, _amount, false)) - 1;
        
        //Event
        expenseCreated(_id, _recipient, _amount);
    }
    
    //Vote On A Law! ATTENTION: You Can't Change Your Vote And You Won't Be Able to Vote On Older Laws
    function voteLaw(uint _lawNb, bool decision) public {
        //Constraints
        require(lastLawVoted[msg.sender]<_lawNb);
        require(laws[_lawNb].acceptance > 0);
        //Require Fees Paid                         //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO

        //Vote
        if (decision = true) {
            laws[_lawNb].acceptance = laws[_lawNb].acceptance + perming[msg.sender];
        } else {
            laws[_lawNb].discord = laws[_lawNb].discord + perming[msg.sender];
        }

        //Update Law Last Vote        
        lastLawVoted[msg.sender] = _lawNb;
    
        //Event
        lawVoted(_lawNb, msg.sender, decision);
    }
    
    //Vote On An Expense! ATTENTION: You Can't Change Your Vote And You Won't Be Able to Vote On Older Expenses
    function voteExpense(uint _expenseNb, bool decision) public {
        //Constraints
        require(lastExpenseVoted[msg.sender]<_expenseNb);
        require(expenses[_expenseNb].acceptance > 0);
        //Require Fees Paid                         //TODO //TODO //TODO //TODO //TODO //TODO //TODO //TODO

        //Vote
        if (decision = true) {
            expenses[_expenseNb].acceptance = laws[_expenseNb].acceptance + perming[msg.sender];
        } else {
            expenses[_expenseNb].discord = laws[_expenseNb].discord + perming[msg.sender];
        }

        //Update Last Expense Vote        
        lastExpenseVoted[msg.sender] = _expenseNb;
    
        //Event
        expenseVoted(_expenseNb, msg.sender, decision);

        if (expenses[_expenseNb].acceptance - expenses[_expenseNb].discord >= minPermingForQuorum && expenses[_expenseNb].paid == false) {
            expenses[_expenseNb].paid = true;
            expenses[_expenseNb].recipient.transfer(expenses[_expenseNb].amount);

            //Event
            expensePaid(_expenseNb, expenses[_expenseNb].recipient, expenses[_expenseNb].amount);
        }
    }
    
}