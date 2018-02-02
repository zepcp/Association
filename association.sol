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
	address associationAccount; //TO DO 

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
		//Give ownership of each fraction
		uint _i;
		while (_perming[_i] > 0) {
	        perming[_owners[_i]] = _perming[_i];
			i++;
	    }
	    
		//Initialize Contract Variables
		creationDate=now;
		monthlyFee=_monthlyFee;
		minPermingForQuorum=_minPermingForQuorum;
		//Set Association Account //TO DO
	}
	
	//Sell Your Association Fraction, Or A Portion Of It
	function sellFraction(address _newOwner, uint _permingGiven) public {
	    //Constraints
		require(perming[msg.sender] >= _permingGiven);
		//Require Fees Paid //TO DO
		
		//Make Transaction: 1st Transfer Perming
		perming[_newOwner] = perming[_newOwner] + _permingGiven;}
		
	
}
