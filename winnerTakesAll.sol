pragma solidity ^0.4.11;

contract WinnerTakesAll {
    
    uint minimumEntryFee;
    uint public deadlineCompaign;
    uint public deadlineProject;
    uint public winningFunds;
    address public winningAddress;
    
    struct Project{
        address addres;
        string name;
        string url;
        uint funds;
        bool initialized;
    }
    
    mapping (address => Project) projects;
    address[] public projectAddresses;
    uint countProjects;
    
    function WinnerTakesAll(uint _minimumEntryFee, uint _durationProjects, uint _durationCampaign) public{
        require(_durationCampaign >= _durationProjects);
        
        minimumEntryFee = _minimumEntryFee;
        deadlineProject = now + _durationProjects;
        deadlineCompaign = now + _durationCampaign;
        winningAddress = msg.sender;
        winningFunds = 0;
    }
    
    function addProject(string name, string url) payable public returns(bool){
        require(msg.value > minimumEntryFee);
        require(now < deadlineProject);
        
        if(!projects[msg.sender].initialized){
            projects[msg.sender] = Project(msg.sender, name, url, 0, true);

            projectAddresses.push(msg.sender);
            countProjects = projectAddresses.length;
            return true;
        }
        return false;
    }
    
    function supportProject(address addr) payable public returns (bool success) {
        require(msg.value >= 0);
        require(now < deadlineCompaign || now >= deadlineProject);
        require(projects[addr].initialized);

        projects[addr].funds += msg.value;
        if (projects[addr].funds > winningFunds) {
            winningAddress = addr;
            winningFunds = projects[addr].funds;
        }
        return true;
    }
    
    function getProjectInfo(address addr) public constant returns (string name, string url, uint funds) {
        var project = projects[addr];
        require(project.initialized);

        return (project.name, project.url, project.funds);
    }
    
    function finish() public {
        if (now >= deadlineCompaign) {
            selfdestruct(winningAddress);
        }
    }
}
