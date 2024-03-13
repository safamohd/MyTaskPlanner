import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/models/skill.dart';
import 'package:my_task_planner/screens/skill_details_screen.dart';
import 'package:my_task_planner/services/database_service.dart';
import 'package:my_task_planner/utils/dialog_util.dart';
import 'package:my_task_planner/utils/trans_util.dart';
import 'package:my_task_planner/widgets/item_grid_skill.dart';

class SkillsScreen extends StatefulWidget {
  static const ROUTE_NAME = "/SkillsScreen";
  const SkillsScreen({Key key}) : super(key: key);

  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _dbService = DBService();
  List<Skill> _skillsList = [];
  var _isLoading = false;

  set isLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    isLoading = true;
    _skillsList = await _dbService.getAllSkills();
    isLoading = false;
  }

  void _addNewSkill() async {
    final result = await DialogUtil.showNewSkillDialog(context);
    if (result == null) return;

    final addedSkill = await _dbService.addNewSkill(result);
    if (addedSkill == null) return;

    setState(() {
      _skillsList.add(addedSkill);
    });
  }

  void _openSkillDetails(Skill skill) async {
    final skillDetailsResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builder) => SkillDetailsScreen(
          skill: skill,
        ),
      ),
    );
    if (skillDetailsResult == skill.id) {
      // the skill id is sent only in case the delete functionality
      // is triggered and finished successfully
      setState(() {
        _skillsList.removeWhere((element) => element.id == skillDetailsResult);
      });
      return;
    }
    if (skillDetailsResult is Skill && skill.equals(skillDetailsResult)) {
      // ignore, no changes have been made on this skill
      return;
    }
    final modifiedSkillIndex = _skillsList.indexWhere((element) => element.id == skill.id);
    setState(() {
      // get the index of the current skill object
      // then replace it with the new modified one
      _skillsList.elementAt(modifiedSkillIndex);
      _skillsList[modifiedSkillIndex] = skillDetailsResult;
    });
    final result = await _dbService.updateSkill(skillDetailsResult);

    // updating done successfully
    if (result != null) return;

    // an error occurred while updating item set the old object back
    setState(() {
      _skillsList[modifiedSkillIndex] = skill;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TransUtil.trans("title_skills_screen"),
        ),
        actions: [
          IconButton(
            onPressed: _addNewSkill,
            icon: Icon(
              Icons.add_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: marginStandard),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _skillsList.isEmpty
                ? InkWell(
                    onTap: _addNewSkill,
                    child: Center(
                      child: Text(
                        TransUtil.trans("msg_no_skills_tap_to_add"),
                      ),
                    ))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // childAspectRatio: 2 / 1,
                      crossAxisCount: 2,
                      crossAxisSpacing: marginStandard,
                      mainAxisSpacing: marginStandard,
                    ),
                    itemCount: _skillsList.length,
                    itemBuilder: (ctx, index) {
                      return FittedBox(
                        child: SkillGridItem(
                          skill: _skillsList[index],
                          onTap: () => _openSkillDetails(_skillsList[index]),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
